{ config, ... }:
{
  sops = {
    # See <https://github.com/Mic92/sops-nix>.
    age.keyFile = "/dev/null"; # For a production configuration, set this option.
    defaultSopsFile = "/dev/null"; # For a production configuration, set this option.
    validateSopsFiles = false; # For a production configuration, remove this line.

    secrets."pdfding/minio/user" = { };
    secrets."pdfding/minio/password" = { };

    templates."minio-creds" = {
      content = ''
        MINIO_ROOT_USER=${config.sops.placeholder."pdfding/minio/user"}
        MINIO_ROOT_PASSWORD=${config.sops.placeholder."pdfding/minio/password"}
      '';
      owner = "minio";
      group = "minio";
    };

    templates."pdfding-minio-keys" = {
      content = ''
        BACKUP_ACCESS_KEY=${config.sops.placeholder."pdfding/minio/user"}
        BACKUP_SECRET_KEY=${config.sops.placeholder."pdfding/minio/password"}
      '';
      owner = config.services.pdfding.user;
      group = config.services.pdfding.group;
    };

    secrets."pdfding/django/secret_key_file" = {
      owner = config.services.pdfding.user;
      group = config.services.pdfding.group;
    };
  };

  services.pdfding = {
    enable = true;
    secretKeyFile = config.sops.secrets."pdfding/django/secret_key_file".path;
    backup.enable = true;
    extraEnvironment = {
      # huey docs say not possible to go lower than 1 min
      # https://huey.readthedocs.io/en/latest/api.html#crontab
      BACKUP_SCHEDULE = "*/1 * * * *";
      BACKUP_ENDPOINT = "127.0.0.1:9000";
    };
    envFiles = [ config.sops.templates."pdfding-minio-keys".path ];
  };

  users.users.pdfding.extraGroups = [ "minio" ]; # allow reading creds

  services.minio = {
    enable = true;
    rootCredentialsFile = config.sops.templates."minio-creds".path;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
  };

  networking.firewall.allowedTCPPorts = [
    9000
    9001
  ];
}
