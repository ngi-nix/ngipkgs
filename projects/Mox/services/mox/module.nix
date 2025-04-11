{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mox;
in
{
  options = {
    services.mox = {
      enable = lib.mkEnableOption "Mox";
      package = lib.mkPackageOption pkgs "mox" { };
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

  config = lib.mkIf cfg.enable {
    # Ensure neccesary packages are installed
    environment.systemPackages = [
      cfg.package
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
    users.groups.mox = { };

    systemd.services.mox-setup = {
      description = "Mox Setup";
      wantedBy = [ "multi-user.target" ];
      requires = [
        "network-online.target"
      ];
      after = [
        "network-online.target"
      ];
      before = [ "mox.service" ];
      serviceConfig = {
        WorkingDirectory = "/var/lib/mox";
        Type = "oneshot";
        RemainAfterExit = true;
        User = "mox";
        Group = "mox";
        ExecStart = "${pkgs.mox}/bin/mox -config /var/lib/mox/config/mox.conf serve";
      };
      script = ''
        mkdir -p /var/lib/mox
        cd /var/lib/mox
        ${pkgs.mox}/bin/mox quickstart -hostname ${config.services.mox.hostname} ${config.services.mox.user}
      '';
    };

    systemd.services.mox = {
      wantedBy = [ "multi-user.target" ];
      after = [ "mox-setup.service" ];
      requires = [ "mox-setup.service" ];
      serviceConfig = {
        WorkingDirectory = "/var/lib/mox";
        ExecStart = "${pkgs.mox}/bin/mox -config /var/lib/mox/config/mox.conf serve";
        Restart = "always";
      };
    };
  };
}
