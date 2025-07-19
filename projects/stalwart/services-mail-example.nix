{
  config,
  pkgs,
  ...
}:

{
  sops = {
    # See <https://github.com/Mic92/sops-nix>.

    age.keyFile = "/dev/null"; # For a production configuration, set this option.
    defaultSopsFile = "/dev/null"; # For a production configuration, set this option.
    validateSopsFiles = false; # For a production configuration, remove this line.

    secrets =
      let
        stalwartSecret = {
          owner = "stalwart-mail";
          group = "stalwart-mail";
        };
      in
      {
        "stalwart_admin_password" = stalwartSecret;
      };
  };

  services.stalwart-mail = {
    enable = true;
    openFirewall = true;
    credentials = {
      user_admin_password = config.sops.secrets."stalwart_admin_password".path;
    };
    settings = {
      server.hostname = "mail.ngi.nixos.org";
    };
    server.listener = {
      "smtp-submission" = {
        bind = [ "[::]:587" ];
        protocol = "smtp";
      };

      "imap" = {
        bind = [ "[::]:143" ];
        protocol = "imap";
      };

      "http" = {
        bind = [ "[::]:80" ];
        protocol = "http";
      };
    };
  };
}
