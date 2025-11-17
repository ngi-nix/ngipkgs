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
    CONSUME_SCHEDULE = cfg.consume.schedule;
  }
  // optionalAttrs cfg.backup.enable {
    BACKUP_ENABLE = "TRUE";
    BACKUP_ENDPOINT = cfg.backup.endpoint;
    BACKUP_SCHEDULE = cfg.backup.schedule;
  }
  // cfg.extraEnvironment;

  envFile = pkgs.writeText "pdfding.env" (
    concatStringsSep "\n" (
      mapAttrsToList (name: value: "${name}=\"${toString value}\"") (filterAttrs (n: v: v != "") envVars)
    )
  );

  loadCreds =
    optionalString usePostgres ''
      export POSTGRES_PASSWORD="$(<${cfg.database.passwordFile})"
    ''
    + ''
      export SECRET_KEY="$(<${cfg.secretKeyFile})"
    '';

  secretRecommendation = "Consider using a secret managing scheme such as `agenix` or `sops-nix` to generate this file.";
in
{
  options.services.pdfding = {
    enable = mkEnableOption "PdfDing service" // {
      description = ''
        Whether to enable pdfding.

        To use the management CLI (pdfding-manage), add your user to the pdfding group:
          users.users.<youruser>.extraGroups = [ "pdfding" ];
      '';
    };

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

    gunicorn.extraArgs = mkOption {
      type = types.listOf types.str;
      description = "Command line arguments passed to Gunicorn server.";
      default = [
        "--workers=4"
        "--max-requests=1200"
        "--max-requests-jitter=50"
        "--log-level=error"
      ];
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
        description = ''
          Bulk PDF import from consume directory.

          When enabled, administrators can create per-user directories like /var/lib/pdfding/consume/<user_id>
          with permissions allowing the pdfding user to read and write.
          PDFs placed in these directories are automatically imported into user accounts.

          PDFs are imported periodically via cronjob and successfully imported files
          are automatically deleted from the consume directory.
        '';
      };
      schedule = mkOption {
        type = types.str;
        default = "*/5 * * * *";
        description = ''
          The cron schedule for the consume task to trigger.
          The format is "minute hour day month day_of_week"
          Read
            - https://github.com/mrmn2/PdfDing/blob/d0f21ec2f9fbee4b1a2f6b7e0e6c7ea7784ab1bc/pdfding/base/task_helpers.py#L5
            - https://huey.readthedocs.io/en/latest/api.html#crontab
        '';
      };
    };

    backup = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Automatic backup of important data to a MinIO instance.

          When enabled and properly configured via environment variables,
          important data is periodically uploaded to the specified MinIO
          instance via cronjob.
        '';
      };
      schedule = mkOption {
        type = types.str;
        default = "0 2 * * *";
        description = ''
          The cron schedule for the consume task to trigger.
          The format is "minute hour day month day_of_week"
          Read
            - https://github.com/mrmn2/PdfDing/blob/d0f21ec2f9fbee4b1a2f6b7e0e6c7ea7784ab1bc/pdfding/base/task_helpers.py#L5
            - https://huey.readthedocs.io/en/latest/api.html#crontab
        '';
      };
      endpoint = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "The Minio endpoint for backups";
        example = "127.0.0.1:9000";
      };
    };

    openFirewall = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Open ports in the firewall for the PdfDing web interface.";
    };

    installWrapper = mkOption {
      type = types.bool;
      default = false;
      description = ''
        This will add pdfding-manage django admin cli with proper credentials configured
        to environment.systemPackages
      '';
    };

    installTestHelpers = mkOption {
      type = types.bool;
      default = false;
      internal = true;
      description = "Adds a few helper commands to systemPackages for nixos tests";
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
      {
        assertion = cfg.database.createLocally -> usePostgres;
        message = "services.pdfding.database.createLocally is enabled but not database.type is not postgres";
      }
    ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    environment.systemPackages =
      let
        genWrapper =
          name: cmd:
          pkgs.writeShellScriptBin name ''
            set -eou pipefail
            set -a
            ${lib.toShellVars cfg.extraEnvironment}
            ${lib.concatMapStringsSep "\n" (f: "source ${f}") cfg.envFiles}
            set +a
            ${loadCreds}
            ${cmd}
          '';
        pdfding-manage = genWrapper "pdfding-manage" ''
          ${config.security.wrapperDir}/sudo -E -u ${cfg.user} ${lib.getExe cfg.package} "$@"
        '';
        consume-immediate = genWrapper "consume-immediate" ''
          echo "from pdf.tasks import consume_function; consume_function(True)" | \
            ${config.security.wrapperDir}/sudo -E -u ${cfg.user} ${lib.getExe cfg.package} shell
        '';
        backup-immediate = genWrapper "backup-immediate" ''
          echo "from backup.tasks import backup_function; backup_function()" | \
            ${config.security.wrapperDir}/sudo -E -u ${cfg.user} ${lib.getExe cfg.package} shell
        '';
      in
      lib.optionals cfg.installWrapper [ pdfding-manage ]
      ++ lib.optionals cfg.installTestHelpers [
        consume-immediate
        backup-immediate
      ];

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.${cfg.group} = { };

    services.pdfding.envFiles = [ envFile ];

    systemd.services.pdfding = {
      description = "PdfDing Web Service";
      after = [ "network.target" ];
      bindsTo =
        (optional usePostgres "postgresql.target")
        ++ (optional cfg.database.createLocally "pdfdingPostgreSQLInit.service");
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
        mkdir -p ${cfg.dataDir}/{db,media}

        ${optionalString cfg.consume.enable ''
          mkdir -p ${cfg.dataDir}/consume
        ''}

        ${cfg.package}/bin/pdfding-manage migrate
        ${cfg.package}/bin/pdfding-manage clean_up
      '';

      serviceConfig = {
        Type = "exec";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = pkgs.writeShellScript "exec-start" ''
          ${loadCreds}
          exec ${cfg.package}/bin/pdfding-start ${builtins.toString cfg.gunicorn.extraArgs}
        '';
        EnvironmentFile = cfg.envFiles;
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
      script =
        # bash
        ''
          set -o errexit -o pipefail -o nounset -o errtrace
          shopt -s inherit_errexit

          create_role="$(mktemp)"
          trap 'rm -f "$create_role"' EXIT

          # escape any single quotes by adding additional single
          # quotes after them, following the rules laid out here:
          # https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-CONSTANTS
          POSTGRES_PASSWORD="$(<"$CREDENTIALS_DIRECTORY/db_password")"
          POSTGRES_PASSWORD="''${POSTGRES_PASSWORD//\'/\'\'}"

          echo "CREATE ROLE pdfding WITH LOGIN PASSWORD '$POSTGRES_PASSWORD' CREATEDB" > "$create_role"
          psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='pdfding'" | grep -q 1 || psql -tA --file="$create_role"
          psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'pdfding'" | grep -q 1 || psql -tAc 'CREATE DATABASE "pdfding" OWNER "pdfding"'
        '';
      enableStrictShellChecks = true;
    };
  };
}
