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

  # only create a local database if we're gonna connect to it locally
  localDB = cfg.database.createLocally;
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

    user = mkOption {
      type = types.nonEmptyStr;
      default = "sstorytime";
      description = "User account under which SSTorytime runs.";
    };

    group = mkOption {
      type = types.nonEmptyStr;
      default = "sstorytime";
      description = "Group under which SSTorytime runs.";
    };

    database = {
      createLocally = mkEnableOption "configure a local PostgreSQL database for SSTorytime.";

      host = mkOption {
        type = types.str;
        default = "/var/run/postgresql";
        example = "192.168.23.42";
        description = "Database host address or unix socket.";
      };

      port = mkOption {
        type = with types; nullOr port;
        default = if localDB then null else 5432;
        defaultText = lib.literalExpression ''
          if `config.services.sstorytime.database.host` is `localhost` or `/run/postgresql`
          then null
          else 5432
        '';
        description = "Database host port.";
      };

      dbname = mkOption {
        type = types.str;
        default = "sstoryline";
        description = "Database name.";
      };

      user = mkOption {
        type = types.str;
        default = "sstoryline";
        description = "Database user.";
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/var/run/secrets/db-password";
        description = ''
          Path to a file containing the PostgreSQL password for
          {option}`database.user`.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = localDB -> cfg.database.passwordFile != null;
        message = ''
          `services.sstorytime.database.passwordFile` must be set when using a local database.
        '';
      }
    ];

    services.sstorytime.database.createLocally = lib.mkDefault true;

    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "SSTorytime service user";
      home = "/var/lib/sstorytime";
      createHome = true;
      isSystemUser = true;
      group = cfg.group;
    };

    systemd.services.sstorytime = {
      description = "SSTorytime Server";
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        LoadCredential = lib.optionals localDB [
          "db_password:${toString cfg.database.passwordFile}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      environment = {
        SST_SERVER_PORT = toString cfg.port;
        PGHOST = cfg.database.host;
        PGUSER = cfg.database.user;
        PGDATABASE = cfg.database.dbname;
        PGPASSFILE = "%d/db_password";
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
      script = ''
        ${lib.getExe' cfg.package "http_server"}
      '';
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "network.target"
        "sstorytime-setup.service"
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
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [
        cfg.database.dbname
      ];
      authentication = ''
        local  all  all  trust

        # This is a workaround for command connections, which appear to be
        # trying to use tcp/ip instead of sockets.
        # Remove when this is fixed, upstream.
        host ${cfg.database.dbname} ${cfg.database.user} localhost trust
      '';
    };
  };
}
