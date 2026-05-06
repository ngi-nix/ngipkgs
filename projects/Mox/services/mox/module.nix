{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mox;
  mkOptionalPort =
    name:
    lib.mkOption {
      description = ''
        The ${name} port. Set to null if we should leave it unset.
      '';
      type = lib.types.nullOr lib.types.port;
      default = null;
    };
in
{
  options = {
    services.mox = {
      # NOTE: The module uses contextual generated config files for the mox server.
      #       This is currently the most reproducible way to get mox running. However, it might
      #       be possible to use a declarative approach when the sconf config file is supported.
      #       If addition configuration is needed, please edit the file and restart the service.

      enable = lib.mkEnableOption "Mox server";
      package = lib.mkPackageOption pkgs "mox" { };
      configFile = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/mox/config/mox.conf";
        description = ''
          Mox `quickstart` generates configuration files to quickly set up a mox instance.
          This, is by far the easiest and most reproducible way to get mox running. All output from `quickstart`
          is written to `quickstart.log`, including initial admin accounts and passwords. In this module, options
          hostname and user are passed to `quickstart` as arguments and the config file are generated in that context.
        '';
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
      ports = {
        http = mkOptionalPort "http";
        https = mkOptionalPort "https";
        smtp = mkOptionalPort "smtp";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open firewall for the ports defined in `ports`";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      enable = true;

      allowedTCPPorts =
        with lib;
        (
          optional (cfg.ports.http != null) cfg.ports.http
          ++ optional (cfg.ports.https != null) cfg.ports.https
          ++ optional (cfg.ports.smtp != null) cfg.ports.smtp
        );
      allowedUDPPorts = [ 53 ];
    };

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
        ExecStart = "${pkgs.mox}/bin/mox quickstart -hostname ${config.services.mox.hostname} ${config.services.mox.user}";
      };
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
