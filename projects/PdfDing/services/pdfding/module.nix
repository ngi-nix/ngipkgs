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

  stateDir = "/var/lib/pdfding";

  usePostgres = cfg.database.type == "postgres";

  envVars = {
    # HOST_IP is used in the package derivation
    HOST_IP = cfg.hostName;
    # HOST_NAME is a comma seperated string of allowedHosts
    HOST_NAME = concatStringsSep "," cfg.allowedHosts;
    HOST_PORT = toString cfg.port;
    DATABASE_TYPE = if usePostgres then "POSTGRES" else "";
    DATA_DIR = "${stateDir}";
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
      mapAttrsToList (name: value: "${name}=\"${toString value}\"") (
        (filterAttrs (n: v: v != "") envVars)
        // optionalAttrs (usePostgres && cfg.database.createLocally) {
          # Django Uses the unix domain socket
          # if host is set to empty see https://docs.djangoproject.com/en/6.0/ref/settings/#host
          POSTGRES_HOST = "";
        }
      )
    )
  );

  loadCreds =
    optionalString (usePostgres && !cfg.database.createLocally) ''
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
        default = "";
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
        assertion = cfg.backup.enable -> envVars.BACKUP_ENDPOINT != null;
        message = "services.pdfding.extraEnvironment.BACKUP_ENDPOINT must be set when backup is enabled";
      }
      {
        assertion = cfg.database.createLocally -> usePostgres;
        message = "services.pdfding.database.createLocally is enabled but not database.type is not postgres";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.host == "";
        message = "services.pdfding.database.host must be empty when services.pdfding.database.createLocally is enabled";
      }
      {
        assertion = cfg.database.createLocally -> cfg.database.passwordFile == null;
        message = "specifying services.pdfding.database.passwordFile is not supported when used along with a local db setup";
      }
      {
        assertion =
          cfg.database.createLocally
          -> cfg.database.user == cfg.user && cfg.database.user == cfg.database.name;
        message = "services.pdfding.database.user should be the same as services.pdfding.user as well as services.pdfding.database.name when running a local db setup";
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
        consume-immediate =
          genWrapper "consume-immediate"
            #bash
            ''
              sudo=exec
              if [[ "$USER" != ${cfg.user} ]]; then
                sudo='${config.security.wrapperDir}/sudo -E -u ${cfg.user}'
              fi
              echo "from pdf.tasks import consume_function; consume_function(True)" | \
                $sudo ${lib.getExe cfg.package} shell
            '';
        backup-immediate =
          genWrapper "backup-immediate"
            #bash
            ''
              sudo=exec
              if [[ "$USER" != ${cfg.user} ]]; then
                sudo='${config.security.wrapperDir}/sudo -E -u ${cfg.user}'
              fi
              echo "from backup.tasks import backup_function; backup_function()" | \
                $sudo ${lib.getExe cfg.package} shell
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
    };

    users.groups.${cfg.group} = { };

    services.pdfding.envFiles = [ envFile ];

    systemd.services.pdfding = {
      description = "PdfDing Web Service";
      after = [ "network.target" ];
      bindsTo = lib.optionals (usePostgres && cfg.database.createLocally) [ "postgresql.target" ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        ${loadCreds}
        ${optionalString (usePostgres && cfg.database.createLocally)
          # bash
          ''
            until ${pkgs.postgresql}/bin/pg_isready -p ${toString cfg.database.port}; do
              echo "Waiting for PostgreSQL..."
              sleep 1
            done
          ''
        }
        mkdir -p ${stateDir}/{db,media}

        ${optionalString cfg.consume.enable ''
          mkdir -p ${stateDir}/consume
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
        StateDirectory = "pdfding";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
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
        WorkingDirectory = stateDir;
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
        ReadWritePaths = [ stateDir ];
        Restart = "on-failure";
        RestartSec = "5s";
        TimeoutStopSec = 30;
      };
    };

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
