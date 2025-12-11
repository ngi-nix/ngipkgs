{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types
    ;

  cfg = config.services.sstorytime;
  localDB = cfg.createLocalDatabase;
  dbName = "sstoryline";
in
{
  options.services.sstorytime = {
    enable = mkEnableOption "SSTorytime";
    package = mkPackageOption pkgs "sstorytime" { };

    port = mkOption {
      type = types.port;
      description = "Port for the SSTorytime service.";
      default = 8080;
    };

    openFirewall = mkEnableOption "the default ports in the firewall for the SSTorytime server.";
    createLocalDatabase = mkEnableOption "configure a local PostgreSQL database for SSTorytime.";
  };

  config = mkIf cfg.enable {
    services.sstorytime.createLocalDatabase = lib.mkDefault true;

    systemd.services.sstorytime = {
      description = "SSTorytime Server";
      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 5;
        ExecStart = ''
          ${lib.getExe' cfg.package "http_server"}
        '';
      };
      environment = {
        SST_SERVER_PORT = toString cfg.port;
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "network.target"
      ]
      ++ lib.optionals localDB [ "postgresql.target" ];
    };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      cfg.port
    ];

    services.postgresql = mkIf localDB {
      enable = true;
      ensureUsers = [
        {
          name = dbName;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ dbName ];
      authentication = ''
        # This is a workaround for command connections, which appear to be
        # trying to use tcp/ip instead of sockets.
        # Remove when this is fixed, upstream.
        host ${dbName} ${dbName} localhost trust
      '';
    };
  };
}
