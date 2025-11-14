{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    literalExpression
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalAttrs
    optionalString
    types
    ;

  cfg = config.services.pdfding;

  usePostgres = cfg.database.type == "postgres";

  envVars = {
    # HOST_IP is used in the package derivation
    HOST_IP = cfg.hostName;
    # HOST_NAME is a comma seperated string of allowedHosts
    HOST_NAME = concatStringsSep "," cfg.allowedHosts;
    HOST_PORT = toString cfg.port;
    DATABASE_TYPE = if usePostgres then "POSTGRES" else "";
    DATA_DIR = "${cfg.dataDir}";
  }
  // optionalAttrs usePostgres {
    POSTGRES_HOST = cfg.database.host;
    POSTGRES_PORT = toString cfg.database.port;
    POSTGRES_DB = cfg.database.name;
    POSTGRES_USER = cfg.database.user;
  }
  // optionalAttrs cfg.consume.enable {
    CONSUME_ENABLE = "TRUE";
  }
  // optionalAttrs cfg.backup.enable {
    BACKUP_ENABLE = "TRUE";
  }
  // cfg.extraEnvironment;

  envFile = pkgs.writeText "pdfding.env" (
    concatStringsSep "\n" (
      mapAttrsToList (name: value: "${name}=${toString value}") (filterAttrs (n: v: v != "") envVars)
    )
  );

  secretRecommendation = "Consider using a secret managing scheme such as `agenix` or `sops-nix` to generate this file.";
in
{
  options.services.pdfding = {
    enable = mkEnableOption "PdfDing service";

    package = lib.mkPackageOption pkgs "pdfding" { };

    user = mkOption {
      type = types.str;
      default = "pdfding";
      description = "User account under which PdfDing runs";
    };

    group = mkOption {
      type = types.str;
      default = "pdfding";
      description = "Group under which PdfDing runs";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/pdfding";
      description = "Directory for PdfDing state (database, media files)";
    };

    hostName = mkOption {
      type = types.str;
      default = "0.0.0.0";
      example = "pdfding.example.com";
      description = "Listen adress for PdfDing";
    };

    port = mkOption {
      type = types.port;
      default = 8000;
      description = "Port on which PdfDing listens";
    };

    allowedHosts = mkOption {
      type = types.listOf types.str;
      default = [
        "127.0.0.1"
        "localhost"
      ];
      description = "Domains where PdfDing is allowed to run";
    };

    gunicorn = {
      extraArgs = mkOption {
        type = types.str;
        description = "Command line arguments passed to Gunicorn server.";
        defaultText = literalExpression "\"--workers=4 --max-requests=1200 --max-requests-jitter=50 --log-level=error\"";
        default = "--workers=4 --max-requests=1200 --max-requests-jitter=50 --log-level=error";
      };
    };

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      default = {
        DEFAULT_THEME = "dark";
        DEFAULT_THEME_COLOR = "green";
        CSRF_COOKIE_SECURE = "FALSE"; # Tests require it to be False
        SESSION_COOKIE_SECURE = "FALSE";
      };
      description = "Additional environment variables";
    };

    secretKeyFile = mkOption {
      type = types.path;
      default = null;
      description = "File containing the Django SECRET_KEY. ${secretRecommendation}";
      example = "/run/secrets/pdfding-secret-key";
    };

    database = {
      type = mkOption {
        type = types.enum [
          "sqlite"
          "postgres"
        ];
        default = "sqlite";
        description = "Database type to use";
      };

      host = mkOption {
        type = types.str;
        default = "localhost";
        description = "PostgreSQL host";
      };

      port = mkOption {
        type = types.port;
        default = 5432;
        description = "PostgreSQL port";
      };

      name = mkOption {
        type = types.str;
        default = "pdfding";
        description = "PostgreSQL database name";
      };

      user = mkOption {
        type = types.str;
        default = "pdfding";
        description = "PostgreSQL user";
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "File containing POSTGRES_PASSWORD. ${secretRecommendation}";
        example = "/run/secrets/pdfding-db-password";
      };

      createLocally = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to create a local PostgreSQL database automatically";
      };
    };

    huey = {
      enable = mkOption {
        type = types.bool;
        default = cfg.consume.enable || cfg.backup.enable;
        description = "Enable Huey background task worker";
        internal = true;
      };
    };

    consume = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable consume functionality";
      };
    };

    backup = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable backup functionality";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.secretKeyFile != null;
        message = "services.pdfding.secretKeyFile must be set when using PdfDing";
      }
      {
        assertion = usePostgres -> cfg.database.passwordFile != null;
        message = "services.pdfding.database.passwordFile must be set when using PostgreSQL";
      }
    ];

    services.postgresql = mkIf (usePostgres && cfg.database.createLocally) {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = { };

    systemd.services.pdfding = {
      description = "PdfDing Web Service";
      after = [
        "network.target"
      ]
      ++ optional (usePostgres && cfg.database.createLocally) "postgresql.service";
      wants = optional (usePostgres && cfg.database.createLocally) "postgresql.service";
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        ${optionalString usePostgres
          # bash
          ''
            until ${pkgs.postgresql}/bin/pg_isready -h ${cfg.database.host} -p ${toString cfg.database.port}; do
              echo "Waiting for PostgreSQL..."
              sleep 1
            done
          ''
        }
        mkdir -p ${cfg.dataDir}/{db,media,consume}

        ${cfg.package}/bin/pdfding-manage migrate
        ${cfg.package}/bin/pdfding-manage clean_up
      '';

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/pdfding-start ${cfg.gunicorn.extraArgs}";
        EnvironmentFile = [
          envFile
          cfg.secretKeyFile
        ]
        ++ optional (usePostgres && cfg.database.passwordFile != null) cfg.database.passwordFile;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    systemd.services.pdfding-huey = mkIf cfg.huey.enable {
      description = "PdfDing Background Tasks (Huey)";
      after = [ "pdfding.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${cfg.package}/bin/pdfding-manage run_huey";
        EnvironmentFile = [ envFile ];
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStopSec = 30;
      };
    };
  };
}
