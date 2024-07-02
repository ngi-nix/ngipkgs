{
  config,
  pkgs,
  ...
}: let
  storageBase = "/var/lib/peertube";
  storageDir = subdir: "${storageBase}/${subdir}/";
in {
  environment = {
    # Sets the initial password of the root user to a fixed value. Make sure to change the password afterwards!
    etc."peertube-envvars".text = ''
      PT_INITIAL_ROOT_PASSWORD=changeme
    '';
  };

  services.peertube = {
    enable = true;

    # The system user & their group under which peertube will run
    user = "peertube";
    group = "peertube";

    # Do *NOT* use this in production, follow the docs and properly generate a secret here! i.e. using the output of:
    # openssl rand -hex 32
    # https://docs.joinpeertube.org/install/any-os#peertube-configuration
    secrets.secretsFile = pkgs.writeText "secrets.txt" "secrets";

    # Configure locally-running instances of redis server & database.
    database.createLocally = true;
    redis.createLocally = true;

    # Where we're running
    localDomain = "localhost";
    listenWeb = 9000;

    # Example settings, adjust as desired
    settings = {
      listen = {
        hostname = "0.0.0.0";
      };
      log = {
        level = "debug";
      };
      storage = {
        tmp = storageDir "tmp";
        logs = storageDir "logs";
        cache = storageDir "cache";
        plugins = storageDir "plugins";
      };
    };

    plugins = {
      enable = true;

      # The plugins you wish to use.
      plugins = with pkgs; [
        peertube-plugin-akismet
        peertube-plugin-auth-ldap
        peertube-plugin-auth-openid-connect
        peertube-plugin-auth-saml2
        peertube-plugin-auto-block-videos
        peertube-plugin-auto-mute
        peertube-plugin-hello-world
        peertube-plugin-logo-framasoft
        peertube-plugin-matomo
        peertube-plugin-privacy-remover
        peertube-plugin-transcoding-custom-quality
        peertube-plugin-transcoding-profile-debug
        peertube-plugin-video-annotation
        peertube-theme-background-red
        peertube-theme-dark
        peertube-theme-framasoft

        peertube-plugin-livechat
      ];
    };

    # For initial password
    serviceEnvironmentFile = "/etc/peertube-envvars";
  };

  systemd.tmpfiles.settings = let
    dirArgs = {
      mode = "0700";
      inherit (config.services.peertube) user group;
    };
  in {
    "99-peertube-plugins-test-setup" = {
      "${storageBase}".d = dirArgs;
      "${storageDir "tmp"}".d = dirArgs;
      "${storageDir "logs"}".d = dirArgs;
      "${storageDir "cache"}".d = dirArgs;
      "${storageDir "plugins"}".d = dirArgs;
    };
  };
}
