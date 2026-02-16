{
  lib,
  config,
  pkgs,
  ...
}:
let
  # note: In a production deployment use `garage key generate pdfding-key`, along with the steps specified in the getting started guide of garage.
  # (sops-nix or agenix for configuring secrets for garage is out of scope here)
  garageAccessKey = "GK0a0a0a0b0b0b0c0c0c0d0d0d";
  garageSecretKey = "0a0a0a0a0b0b0b0b0c0c0c0c0d0d0d0d1a1a1a1a1b1b1b1b1c1c1c1c1d1d1d1d";
in
{
  services.pdfding = {
    enable = true;
    secretKeyFile = config.sops.secrets."pdfding/django/secret_key".path;

    backup.enable = true;
    backup.schedule = "*/1 * * * *";
    backup.endpoint = "[::]:3900";
    extraEnvironment.BACKUP_BUCKET_NAME = "pdfding-bucket";
    extraEnvironment.BACKUP_REGION = "garage";

    envFiles = [ config.sops.templates."pdfding-s3-keys".path ];
  };

  # Setup a local garage service (s3, minio compatible) for the backup feature
  services.garage = {
    enable = true;
    package = lib.mkForce pkgs.garage_2;
    settings = {
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "[::1]:3901";
      rpc_secret = "5c1915fa04d0b6739675c61bf5907eb0fe3d9c69850c83820f51b4d25d13868c";

      s3_api = {
        s3_region = "garage";
        api_bind_addr = "[::]:3900";
        root_domain = ".s3.garage";
      };

      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.garage";
        index = "index.html";
      };

      replication_factor = 1;
    };
  };

  # setup garage bucket and credentials
  # note: The nixos module has no option to specify secrets declaratively
  systemd.services.garage.postStart = ''
    export PATH="$PATH:${config.services.garage.package}/bin"

    # wait for garage to be up
    while ! garage status >/dev/null 2>&1; do sleep 2; done

    if ! garage bucket list | grep -q pdfding-bucket; then
      garage layout assign -z dc1 -c 1G $(garage status | cut -d' ' -f1 | tail -1)
      garage layout apply --version 1

      garage key import ${garageAccessKey} ${garageSecretKey} -n pdfding-key --yes

      garage bucket create pdfding-bucket

      garage bucket allow --read --write --owner pdfding-bucket --key pdfding-key
    fi
  '';

  # Secrets management
  # See <https://github.com/Mic92/sops-nix>
  sops = {
    age.keyFile = "/dev/null"; # For a production configuration, set this option.
    defaultSopsFile = "/dev/null"; # For a production configuration, set this option.
    validateSopsFiles = false; # For a production configuration, remove this line.

    secrets."pdfding/s3/user" = { };
    secrets."pdfding/s3/password" = { };

    templates."pdfding-s3-keys" = {
      content = ''
        BACKUP_ACCESS_KEY=${config.sops.placeholder."pdfding/s3/user"}
        BACKUP_SECRET_KEY=${config.sops.placeholder."pdfding/s3/password"}
      '';
      owner = config.services.pdfding.user;
      group = config.services.pdfding.group;
    };

    secrets."pdfding/django/secret_key" = {
      owner = config.services.pdfding.user;
      group = config.services.pdfding.group;
    };
  };
}
