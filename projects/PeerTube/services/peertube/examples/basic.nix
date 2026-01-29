{
  config,
  pkgs,
  ...
}:
{
  services.peertube = {
    enable = true;

    # Configure locally-running instances of redis server & database.
    database.createLocally = true;
    redis.createLocally = true;

    # Where we're running
    localDomain = "localhost";
    listenWeb = 9000;

    # Example settings, adjust as desired
    settings = {
      listen.hostname = "0.0.0.0";
      instance.name = "My Lovely PeerTube Instance";
      # Enable livestreaming
      live.enabled = true;
    };

    plugins = {
      enable = true;
      plugins = with pkgs; [
        peertube-theme-dark
        peertube-plugins.video-annotation
        peertube-plugins.livechat
      ];
    };

    # Do *NOT* use this in production, follow the docs and properly generate a secret here! i.e. using the output of:
    # openssl rand -hex 32
    # https://docs.joinpeertube.org/install/any-os#peertube-configuration
    secrets.secretsFile = pkgs.writeText "secrets.txt" "secrets";

    # Set the initial password of the root user to a fixed value. Make sure to change the password afterwards!
    serviceEnvironmentFile = "/etc/peertube-envvars";
  };
  environment.etc."peertube-envvars".text = ''
    PT_INITIAL_ROOT_PASSWORD=changeme
  '';

  networking.firewall.allowedTCPPorts = [
    config.services.peertube.listenWeb
    # Livestreaming port
    1935
  ];
}
