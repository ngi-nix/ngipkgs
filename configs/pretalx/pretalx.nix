{
  config,
  pkgs,
  ...
}: {
  imports = [./vm.nix];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking = {
    firewall.allowedTCPPorts = [config.services.nginx.defaultHTTPListenPort];
    hostName = "server";
    domain = "example.com";
  };

  sops = {
    secrets = let
      pretalxSecret = {
        # For a production configuration also `sopsFile` is required.
        # See <https://github.com/Mic92/sops-nix>.
        owner = config.services.pretalx.user;
        group = config.services.pretalx.group;
      };
    in {
      "pretalx/database/password" = pretalxSecret;
      "pretalx/redis/location" = pretalxSecret;
      "pretalx/init/admin/password" = pretalxSecret;
      "pretalx/celery/backend" = pretalxSecret;
      "pretalx/celery/broker" = pretalxSecret;
    };
  };

  services = {
    pretalx = {
      enable = true;
      package = pkgs.pretalx-full;
      nginx = {
        # For a production configuration use this attribute set to configure the virtual host for pretalx.
      };
      database = {
        user = "pretalx";
        passwordFile = config.sops.secrets."pretalx/database/password".path;
      };
      redis = {
        enable = true;
        locationFile = config.sops.secrets."pretalx/redis/location".path;
      };
      celery = {
        enable = true;
        backendFile = config.sops.secrets."pretalx/celery/backend".path;
        brokerFile = config.sops.secrets."pretalx/celery/broker".path;
      };

      init = {
        admin = {
          email = "pretalx@localhost";
          passwordFile = config.sops.secrets."pretalx/init/admin/password".path;
        };
        organiser = {
          name = "NGI Packages";
          slug = "ngipkgs";
        };
      };
      mail.enable = false;
    };

    redis.servers."pretalx" = {
      enable = true;
      user = config.services.pretalx.user;
    };

    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
    };
  };

  system.stateVersion = "22.11";
}
