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
  localDB = (cfg.database.host == "localhost") || (cfg.database.host == "/run/postgresql");
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

    database = {
      host = mkOption {
        type = types.str;
        default = "localhost";
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

    systemd.services.sstorytime = {
      description = "SSTorytime Server";
      serviceConfig = {
        DynamicUser = true;
        RuntimeDirectory = "sstorytime";
        LoadCredential = lib.optionals localDB [
          "db_password:${toString cfg.database.passwordFile}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      environment = {
        SST_SERVER_PORT = toString cfg.port;
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
      script = ''
        export HOME="''${RUNTIME_DIRECTORY}"
        export CREDENTIALS_FILE="''${HOME}/.SSTorytime"

        cat > "$CREDENTIALS_FILE" <<EOF
        dbname: ${cfg.database.dbname}
        user: ${cfg.database.user}
        passwd: ${
          lib.optionalString (cfg.database.passwordFile != null) ''
            $(cat $CREDENTIALS_DIRECTORY/db_password)
          ''
        }
        EOF

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
        }
      ];
      ensureDatabases = [ cfg.database.dbname ];
    };

    # Set up database password
    # Modified from: https://github.com/NixOS/nixpkgs/pull/326306
    systemd.services.postgresql-setup.postStart = lib.optionalString localDB ''
      psql -tA <<'EOF'
        DO $$
        DECLARE
          role_exists BOOLEAN;
          password TEXT;
        BEGIN
          password := trim(both from replace(pg_read_file('${cfg.database.passwordFile}'), E'\n', '''));

          -- Check if the role exists
          SELECT EXISTS (
              SELECT 1
              FROM pg_roles
              WHERE rolname = '${cfg.database.user}'
          ) INTO role_exists;

          -- Create role if it doesn't already exist, else change its password
          IF NOT role_exists THEN
              EXECUTE format('CREATE ROLE %I WITH PASSWORD %L', '${cfg.database.user}', password);
          ELSE
              EXECUTE format('ALTER ROLE %I WITH PASSWORD %L', '${cfg.database.user}', password);
          END IF;
        END $$;

        ALTER DATABASE "${cfg.database.dbname}" OWNER TO "${cfg.database.user}"
      EOF
    '';
  };
}
