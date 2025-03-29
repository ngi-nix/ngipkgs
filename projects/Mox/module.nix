{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    services.mox = {
      enable = lib.mkEnableOption "Enable Mox Mail Server";
      configFile = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/mox/config/mox.conf";
        description = "Path to the Mox configuration file";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        default = "mail";
        description = "Hostname for the Mox Mail Server";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "*Required* Email user as (user@domain) to be created.";
      };
    };
  };

  config = lib.mkIf config.services.mox.enable {
    # Ensure neccesary packages are installed
    environment.systemPackages = with pkgs; [
      mox
    ];

    # Create a dedicated user/group for Mox
    users.users.mox = {
      isSystemUser = true;
      name = "mox";
      group = "mox";
      home = "/var/lib/mox";
      createHome = true;
      description = "Mox Mail Server User";
    };
    users.groups.mox = {
      name = "mox";
    };

    systemd.services.mox-setup = {
      description = "Setup Mox Mail Server";
      wantedBy = [ "multi-user.target" ];
      before = [ "mox.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p /var/lib/mox
        cd /var/lib/mox
        ${pkgs.mox}/bin/mox quickstart -hostname ${config.services.mox.hostname} ${config.services.mox.user}
        chown -R mox:mox /var/lib/mox
      '';
    };

    systemd.services.mox = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "mox-setup.service" ];
      requires = [ "mox-setup.service" ]; # This ensures mox-setup must succeed
      serviceConfig = {
        WorkingDirectory = "/var/lib/mox";
        ExecStart = "${pkgs.mox}/bin/mox -config /var/lib/mox/config/mox.conf serve";
        Restart = "always";
      };
    };
  };
}
