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
    POSTGRES_PORT = builtins.toString cfg.database.port;
    POSTGRES_HOST = cfg.database.host;
    POSTGRES_NAME = cfg.database.name;
    POSTGRES_USER = cfg.database.user;
  }
  // optionalAttrs cfg.consume.enable {
    CONSUME_ENABLE = "TRUE";
  }
  // optionalAttrs cfg.backup.enable {
    BACKUP_ENABLE = "TRUE";
    BACKUP_ENDPOINT = null;
  }
  // cfg.extraEnvironment;

  envFile = pkgs.writeText "pdfding.env" (
    concatStringsSep "\n" (
      mapAttrsToList (name: value: "${name}=\"${toString value}\"") (filterAttrs (n: v: v != "") envVars)
    )
  );

  loadCreds =
    optionalString usePostgres
      # bash
      ''
        export POSTGRES_PASSWORD="$(<$CREDENTIALS_DIRECTORY/db_password)"
      '';

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

    envFiles = mkOption {
      type = types.listOf types.path;
      description = "Environment variable files";
      default = [ ];
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

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.secretKeyFile != null;
        message = "services.pdfding.secretKeyFile must be set when using PdfDing";
      }
      {
        assertion = usePostgres -> cfg.database.passwordFile != null;
        message = "services.pdfding.database.passwordFile must be set when using PostgreSQL";
      }
      {
        assertion = cfg.backup.enable -> envVars.BACKUP_ENDPOINT != null;
        message = "services.pdfding.extraEnvironment.BACKUP_ENDPOINT must be set when backup is enabled";
      }
    ];

    # TODO finalPackage
    environment.systemPackages = [ ];

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = { };

    services.pdfding.envFiles = [
      cfg.secretKeyFile
      envFile
    ];

    systemd.services.pdfding =
      let
        databaseServices =
          [ ]
          ++ (optional usePostgres "postgresql.target")
          ++ (optional cfg.database.createLocally "pdfdingPostgreSQLInit.service");
      in
      {
        description = "PdfDing Web Service";
        after = [
          "network.target"
        ]
        ++ databaseServices;
        bindsTo = databaseServices;
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          ${loadCreds}
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
          ExecStart = pkgs.writeShellScript "exec-start" ''
            ${loadCreds}
            exec ${cfg.package}/bin/pdfding-start ${cfg.gunicorn.extraArgs}
          '';
          EnvironmentFile = cfg.envFiles;
          LoadCredential = lib.optional usePostgres "db_password:${cfg.database.passwordFile}";
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

    systemd.services.pdfding-huey = lib.mkIf (cfg.consume.enable || cfg.backup.enable) {
      description = "PdfDing Background Tasks (Huey)";
      after = [ "pdfding.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        EnvironmentFile = cfg.envFiles;
        LoadCredential = lib.optional usePostgres "db_password:${cfg.database.passwordFile}";
        ExecStart = pkgs.writeShellScript "exec-start" ''
          ${loadCreds}
          exec ${cfg.package}/bin/pdfding-manage run_huey;
        '';

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

    # postgres setup

    services.postgresql.enable = lib.mkDefault (usePostgres && cfg.database.createLocally);

    # copied from keycloak module in nixpkgs
    systemd.services.pdfdingPostgreSQLInit = lib.mkIf (usePostgres && cfg.database.createLocally) {
      after = [ "postgresql.target" ];
      before = [ "pdfding.service" ];
      bindsTo = [ "postgresql.target" ];
      path = [ config.services.postgresql.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        Group = "postgres";
        LoadCredential = [ "db_password:${cfg.database.passwordFile}" ];
      };
      script = ''
        set -o errexit -o pipefail -o nounset -o errtrace
        shopt -s inherit_errexit

        create_role="$(mktemp)"
        trap 'rm -f "$create_role"' EXIT

        # Read the password from the credentials directory and
        # escape any single quotes by adding additional single
        # quotes after them, following the rules laid out here:
        # https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS
        db_password="$(<"$CREDENTIALS_DIRECTORY/db_password")"
        db_password="''${db_password//\'/\'\'}"

        echo "CREATE ROLE pdfding WITH LOGIN PASSWORD '$db_password' CREATEDB" > "$create_role"
        psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='pdfding'" | grep -q 1 || psql -tA --file="$create_role"
        psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'pdfding'" | grep -q 1 || psql -tAc 'CREATE DATABASE "pdfding" OWNER "pdfding"'
      '';
      enableStrictShellChecks = true;
    };
  };
}
