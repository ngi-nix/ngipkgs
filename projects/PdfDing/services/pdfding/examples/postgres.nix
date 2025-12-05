{ config, ... }:
{
  services.pdfding = {
    enable = true;
    secretKeyFile = config.sops.secrets."pdfding/django/secret_key".path;
    database.createLocally = true;
    database.type = "postgres";
    consume.enable = true; # allows bulk importing pdf files from the backend
    consume.schedule = "*/1 * * * *"; # once every minute
  };

  # Secrets management
  # See <https://github.com/Mic92/sops-nix>
  sops = {
    age.keyFile = "/dev/null"; # For a production configuration, set this option.
    defaultSopsFile = "/dev/null"; # For a production configuration, set this option.
    validateSopsFiles = false; # For a production configuration, remove this line.
    secrets."pdfding/django/secret_key" = {
      owner = config.services.pdfding.user;
      group = config.services.pdfding.group;
    };
  };
}
