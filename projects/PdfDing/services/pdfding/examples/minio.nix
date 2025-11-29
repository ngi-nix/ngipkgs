{ config, ... }:
{
  services.pdfding = {
    enable = true;
    secretKeyFile = config.sops.secrets."pdfding/django/secret_key".path;
    backup.enable = true;
    backup.schedule = "*/1 * * * *";
    backup.endpoint = "127.0.0.1:9000";
    envFiles = [ config.sops.templates."pdfding-minio-keys".path ];
    # adds pdfding-manage django admin executable to path
    installWrapper = true;
  };

  # Setup a local minio service for the backup feature
  services.minio = {
    enable = true;
    rootCredentialsFile = config.sops.templates."minio-creds".path;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
  };

  # Secrets management
  # See <https://github.com/Mic92/sops-nix>
  sops = {
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

    secrets."pdfding/django/secret_key" = {
      owner = config.services.pdfding.user;
      group = config.services.pdfding.group;
    };
  };
}
