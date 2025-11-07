{ config, ... }:
{
  sops = {
    # See <https://github.com/Mic92/sops-nix>.
    age.keyFile = "/dev/null"; # For a production configuration, set this option.
    defaultSopsFile = "/dev/null"; # For a production configuration, set this option.
    validateSopsFiles = false; # For a production configuration, remove this line.
    secrets."pdfding/django/secret_key" = {
      owner = config.services.pdfding.user;
      group = config.services.pdfding.group;
    };
  };

  # sqlite, no huey
  services.pdfding = {
    enable = true;
    secretKeyFile = config.sops.secrets."pdfding/django/secret_key".path;
  };
}
