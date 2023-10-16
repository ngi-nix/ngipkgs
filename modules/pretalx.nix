{
  config,
  lib,
  modulesPath,
  options,
  pkgs,
  ...
}:
with builtins;
with lib; let
  cfg = config.services.pretalx;
  opt = options.services.pretalx;
  gunicorn = pkgs.python3Packages.gunicorn;
  libDir = "/var/lib/pretalx";
  gunicornSocketPath = "/var/run/pretalx.sock";
  gunicornSocket = "unix:${gunicornSocketPath}";
  pretalxWebServiceName = "pretalx-web";

  format = pkgs.formats.ini {};

  extras =
    cfg.package.optional-dependencies.redis
    ++ lib.optionals (cfg.settings.database.backend == "mysql") cfg.package.optional-dependencies.mysql
    ++ lib.optionals (cfg.settings.database.backend == "postgresql") cfg.package.optional-dependencies.postgres;

  PYTHONPATH = "${cfg.package.PYTHONPATH}:${cfg.package.python.pkgs.makePythonPath extras}";

  pretalxWrapped =
    pkgs.runCommand "pretalx-wrapper"
    {nativeBuildInputs = [pkgs.makeWrapper pkgs.python3Packages.wrapPython];}
    ''
      makeWrapper ${cfg.package}/bin/pretalx \
        $out/bin/pretalx --prefix PYTHONPATH : "${PYTHONPATH}"
    '';

  secretRecommendation = "Consider using a secret managing scheme such as `agenix` or `sops-nix` to generate this file.";
in {
  options.services.pretalx = with types; {
    enable = mkEnableOption "pretalx server";

    package = mkPackageOption pkgs "pretalx" {};

    user = mkOption {
      type = str;
      description = "Username of the system user that should own files and services related to pretalx.";
      default = "pretalx";
    };

    group = mkOption {
      type = str;
      description = "Group that contains the system user that executes pretalx.";
      default = "pretalx";
    };

    nginx = mkOption {
      type = types.submodule (
        recursiveUpdate
        (import (modulesPath + "/services/web-servers/nginx/vhost-options.nix") {inherit config lib;}) {}
      );
      default = {};
      example = literalExpression ''
        {
          serverAliases = [
            "pretalx.''${config.networking.domain}"
          ];
          # To enable encryption and let let's encrypt take care of certificate
          forceSSL = true;
          enableACME = true;
        }
      '';
      description = "nginx virtualHost settings.";
    };

    gunicorn = {
      extraArgs = mkOption {
        type = str;
        description = "Command line arguments passed to Gunicorn server.";
        defaultText = literalExpression "\"--workers=4 --max-requests=1200 --max-requests-jitter=50 --log-level=error\"";
        default = "--workers=4 --max-requests=1200 --max-requests-jitter=50 --log-level=error";
      };
    };

    celery = {
      enable = mkEnableOption "support for Celery";

      backendFile = mkOption {
        type = nullOr path;
        description = "Path to a file that contains the location (connection URI) of Celery backend. If you use a standard Redis-based setup, the file should contain `redis://127.0.0.1/1` or similar. Check the documentation <https://docs.celeryq.dev/en/stable/getting-started/backends-and-brokers/redis.html>. ${secretRecommendation}";
        default = null;
        example = "/run/secrets/pretalx/celery-backend";
      };

      brokerFile = mkOption {
        type = nullOr path;
        description = "Path to a file that contains the location (connection URI) of Celery broker. If you use a standard Redis-based setup, the file should contain `redis://127.0.0.1/2` or similar. Check the documentation <https://docs.celeryq.dev/en/stable/getting-started/backends-and-brokers/redis.html>. ${secretRecommendation}";
        default = null;
        example = "/run/secrets/pretalx/celery-broker";
      };

      extraArgs = mkOption {
        type = listOf str;
        default = [];
        description = ''
          Extra arguments to pass to celery.
          See <https://docs.celeryq.dev/en/stable/reference/cli.html#celery-worker> for more info.
        '';
        apply = escapeShellArgs;
      };
    };

    redis = {
      enable = mkEnableOption "support for Redis";

      locationFile = mkOption {
        type = path;
        description = ''
          Path to a file that contains the location (connection URI) of Redis server, if you want to use it as a cache. Contents of the file: `redis://[:password]@127.0.0.1:6379/1` would be sensible, or `unix://[:password]@/path/to/socket.sock?db=0` if you prefer to use sockets. ${secretRecommendation}
        '';
        example = "/run/secrets/pretalx/redis";
      };
    };

    init = {
      admin = {
        email = mkOption {
          type = str;
          description = "E-mail address of the administrator.";
          example = "admin@example.com";
        };

        passwordFile = mkOption {
          type = path;
          description = "Path to a file containing the administrator password. ${secretRecommendation}";
          example = "/run/secrets/pretalx/admin";
        };
      };

      organiser = {
        name = mkOption {
          type = str;
          description = "Name of the conference organiser.";
          example = "The Conference Organiser";
        };

        slug = mkOption {
          type = str;
          description = "Slug of the conference organiser (to be used in URLs).";
          example = "conforg";
        };
      };
    };

    secrets = {
      site = {
        secretFile = mkOption {
          type = nullOr path;
          description = "Path to a file containing a secret key that the Django web framework uses for cryptographic signing. See <https://docs.pretalx.org/administrator/configure.html#secret>. ${secretRecommendation}";
          default = null;
          example = "/run/secrets/pretalx/secret";
        };
      };

      database = {
        passwordFile = mkOption {
          type = nullOr path;
          description = "Path to a file containing the database password. If you use PostgreSQL, consider using its peer authentication and not setting a password. ${secretRecommendation}";
          default = null;
          example = "/run/secrets/pretalx/database";
        };
      };

      mail = {
        passwordFile = mkOption {
          type = path;
          description = "Path to a file containing the password for SMTP server authentication. ${secretRecommendation}";
          example = "/run/secrets/pretalx/mail";
        };
      };
    };

    settings = mkOption {
      type = submodule {
        freeformType = format.type;
        options = {
          filesystem = {
            data = mkOption {
              type = path;
              description = ''
                Path that is the base for all other directories (see options `media`, `static`, `logs`). Unless you have a compelling reason to keep other files apart, setting this option is the easiest way to configure file storage.
              '';
              default = libDir + "/data";
            };

            media = mkOption {
              type = str;
              description = ''
                Directory that contains user generated files. It needs to be writable by the pretalx process.
              '';
              default = "${cfg.settings.filesystem.data}/media";
              defaultText = literalExpression "\"\${cfg.settings.filesystem.data}/media\"";
            };

            logs = mkOption {
              type = path;
              description = ''
                Directory that contains logged data. It needs to be writable by the pretalx process.
              '';
              default = "/var/log/pretalx";
            };

            static = mkOption {
              type = pathInStore;
              description = ''
                Directory that contains static files. It needs to be writable by the pretalx process. pretalx will put files there.
              '';
              default = "${cfg.package.static}";
              defaultText = literalExpression "\${config.${opt.package}}.static}/";
              readOnly = true;
            };
          };

          site = let
            cspOption = mkOption {
              type = nullOr str;
              description = ''
                Use this setting to update the CSP security headers.
                See <https://docs.pretalx.org/administrator/configure.html#csp-csp-script-csp-style-csp-img-csp-form>.
              '';
              default = null;
              example = "https://example.com,'self'";
            };
          in {
            url = mkOption {
              type = str;
              description = ''
                URL for pretalx. pretalx uses this value when it has to render full URLs, for example in emails or feeds. It is also used to determine the allowed incoming hosts.
              '';
              default = "http://${config.networking.fqdn}/";
              defaultText = literalExpression "\"http://\${config.networking.fqdn}/\"";
              example = "http://pretalx.example.com";
            };

            media = mkOption {
              type = str;
              description = "Path that is appended to the site URL to address media files (all files uploaded by users or generated by pretalx).";
              default = "/media/";
            };

            static = mkOption {
              type = str;
              description = "Path that is appended to the site URL to address static files.";
              default = "/static/";
            };

            csp = cspOption;
            csp_script = cspOption;
            csp_style = cspOption;
            csp_img = cspOption;
            csp_form = cspOption;
          };

          database = {
            backend = mkOption {
              type = enum ["postgresql" "mysql" "sqlite3"];
              default = "postgresql";
              description = ''
                The default is SQLite ("sqlite3"), which is not a production
                database. Please use a database like PostgreSQL ("postgresql") or MySQL ("mysql").
              '';
            };

            name = mkOption {
              type = str;
              description = "Database name. If you use SQLite, this is the filesystem path to the database file.";
              default = "pretalx";
            };

            user = mkOption {
              type = nullOr str;
              default = "pretalx";
              description = mdDoc ''
                Database username. This value can be `null` for SQLite database.
              '';
            };

            host = mkOption {
              type = nullOr path;
              default =
                if cfg.settings.database.backend == "postgresql"
                then "/run/postgresql"
                else if cfg.settings.database.backend == "mysql"
                then "/run/mysqld/mysqld.sock"
                else null;
              defaultText = literalExpression ''
                if config.${opt.settings}.database.backend == "postgresql" then "/run/postgresql"
                else if config.${opt.settings}.database.backend == "mysql" then "/run/mysqld/mysqld.sock"
                else null
              '';
              description = "Database host, or path to a socket (if you use PostgreSQL or MySQL). For local PostgreSQL authentication, you can leave this variable empty.";
              example = "localhost";
            };

            port = mkOption {
              type = nullOr int;
              description = "Database port (e.g. `5432` for PostgreSQL or `3306` for MySQL).";
              default = null;
              example = "5432";
            };
          };

          mail = {
            from = mkOption {
              type = nullOr str;
              description = "Fall-back sender address, e.g. for when pretalx sends event-independent e-mails.";
              example = "admin@localhost";
              default = null;
            };

            host = mkOption {
              type = nullOr str;
              description = "Hostname of the SMTP server for sending e-mails.";
              default = "localhost";
            };

            port = mkOption {
              type = int;
              description = "TCP port of the SMTP server for sending e-mails.";
              default = 25;
            };

            user = mkOption {
              type = nullOr str;
              description = "Username for SMTP server authentication.";
              default = null;
              example = "admin";
            };

            tls = mkOption {
              type = bool;
              description = "Whether to use TLS for sending mail.";
              default = false;
            };

            ssl = mkOption {
              type = bool;
              description = "Whether to use SSL for sending mail.";
              default = true;
            };
          };

          logging = {
            email = mkOption {
              type = nullOr str;
              description = "E-mail address (or comma-separated list of addresses) to send system logs to.";
              example = "root@example.com,admin@example.com";
              default = null;
            };

            email_level = mkOption {
              type = enum ["DEBUG" "INFO" "WARNING" "ERROR" "CRITICAL"];
              description = "Log level to start sending emails at.";
              default = "ERROR";
            };
          };

          locale = {
            language_code = mkOption {
              type = str;
              description = "Default locale.";
              default = "en";
            };
            time_zone = mkOption {
              type = str;
              description = ''
                Default time zone as a `pytz` name.

                You can use following code to generate the full list of timezone names:

                ```python
                import pytz

                print(pytz.all_timezones)
                ```
              '';
              default = "UTC";
            };
          };
        };
      };
      default = {};
      example = "{ site.debug = true; }";
      description = mdDoc ''
        pretalx configuration as a Nix attribute set. All settings can also be passed
        from the environment.
        See <https://docs.pretalx.org/administrator/configure.html> for possible options.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings.mail.tls && cfg.settings.mail.ssl);
        message = "Enable either `${opt.settings.mail.tls}` or `${opt.settings.mail.ssl}`.";
      }
    ];

    services = {
      nginx = {
        enable = mkDefault true;
        virtualHosts.${pretalxWebServiceName} = mkMerge [
          cfg.nginx
          {
            locations."/".proxyPass = "http://${pretalxWebServiceName}";
          }
        ];
        upstreams.${pretalxWebServiceName}.servers."${gunicornSocket}".fail_timeout = "0";
      };

      pretalx.settings.redis.session = mkDefault cfg.redis.enable;
    };

    users.users."${cfg.user}" = {
      isSystemUser = true;
      createHome = true;
      home = libDir;
      group = cfg.group;
    };

    users.groups."${cfg.group}" = {};

    environment.systemPackages = [
      pretalxWrapped
    ];

    environment.etc."pretalx/pretalx.cfg".source = let
      pretalxCfg =
        # Removes empty attrsets, otherwise `format.generate` will fail.
        filterAttrs (n: v: v != {})
        (
          filterAttrsRecursive (n: v: (v != null))
          cfg.settings
        );
    in
      format.generate "pretalx.cfg" pretalxCfg;

    systemd = let
      commonUnitConfig = {
        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = "pretalx";
          LogsDirectory = "pretalx";
          WorkingDirectory = libDir;
          RuntimeDirectory = "pretalx";
          SupplementaryGroups = ["redis-pretalx"];
        };
        after =
          []
          ++ lib.optionals cfg.redis.enable ["redis-pretalx.service"]
          ++ lib.optionals (cfg.settings.database.backend == "postgresql") ["postgresql.service"]
          ++ lib.optionals (cfg.settings.database.backend == "mysql") ["mysql.service"];
      };
    in {
      sockets."pretalx-web" = {
        listenStreams = [gunicornSocketPath];
        socketConfig.SocketUser = config.services.nginx.user;
        wantedBy = ["sockets.target"];
      };
      services = let
        catFile = varname: filename: "export ${varname}=\"$(cat ${filename})\"";
        exportPasswordEnv = lib.concatStringsSep "\n" ([]
          ++ optional cfg.settings.mail.enable (catFile "PRETALX_MAIL_PASSWORD" cfg.secrets.mail.passwordFile)
          ++ optional (cfg.secrets.database.passwordFile != null) (catFile "PRETALX_DB_PASS" cfg.secrets.database.passwordFile)
          ++ optional cfg.redis.enable (catFile "PRETALX_REDIS" cfg.redis.locationFile)
          ++ optional (cfg.secrets.site.secretFile != null) (catFile "SECRET_KEY" cfg.secrets.site.secretFile)
          ++ optional cfg.celery.enable ''
            ${catFile "PRETALX_CELERY_BACKEND" cfg.celery.backendFile}
            ${catFile "RESULT_BACKEND" cfg.celery.brokerFile}
            ${catFile "PRETALX_CELERY_BROKER" cfg.celery.brokerFile}
            ${catFile "BROKER_URL" cfg.celery.brokerFile}
          '');
        mkOneshot = command:
          recursiveUpdate commonUnitConfig {
            serviceConfig = {
              Type = "oneshot";
            };
            script = ''
              ${exportPasswordEnv}
              ${pretalxWrapped}/bin/pretalx ${command}
            '';
          };
      in {
        ${pretalxWebServiceName} = recursiveUpdate commonUnitConfig {
          serviceConfig = {
            Restart = "on-failure";
          };
          environment.PYTHONPATH = PYTHONPATH;
          script = ''
            ${exportPasswordEnv}

            exec ${gunicorn}/bin/gunicorn pretalx.wsgi --name=${pretalxWebServiceName} --bind=${gunicornSocket} ${cfg.gunicorn.extraArgs}
          '';
          wantedBy = ["multi-user.target"];
          requires = ["pretalx-init.service" "pretalx-web.socket"];
          after = ["pretalx-init.service"];
        };

        pretalx-init = recursiveUpdate commonUnitConfig {
          unitConfig.ConditionPathExists = "!${libDir}/init-will-not-run-again-if-this-file-exists";
          serviceConfig.Type = "oneshot";
          environment = {
            PRETALX_INIT_ORGANISER_NAME = cfg.init.organiser.name;
            PRETALX_INIT_ORGANISER_SLUG = cfg.init.organiser.slug;
            DJANGO_SUPERUSER_EMAIL = cfg.init.admin.email;
          };
          script = ''
            ${exportPasswordEnv}
            export DJANGO_SUPERUSER_PASSWORD=$(cat ${cfg.init.admin.passwordFile})
            ${pretalxWrapped}/bin/pretalx init --noinput
            touch ${libDir}/init-will-not-run-again-if-this-file-exists
          '';
          requires = ["pretalx-migrate.service"];
          after = ["network.target" "pretalx-migrate.service"];
        };

        pretalx-migrate = mkOneshot "migrate";
        pretalx-clearsessions = mkOneshot "clearsessions";
        pretalx-runperiodic = mkOneshot "runperiodic";

        pretalx-worker = mkIf cfg.celery.enable (recursiveUpdate commonUnitConfig {
          description = "pretalx asynchronous job runner";
          environment.PYTHONPATH = PYTHONPATH;
          after = commonUnitConfig.after ++ ["network.target"];
          wantedBy = ["multi-user.target"];
          script = ''
            ${exportPasswordEnv}
            ${cfg.package.python.pkgs.celery}/bin/celery --app pretalx.celery_app worker ${cfg.celery.extraArgs}
          '';
        });
      };

      timers = let
        mkTimer = {
          description,
          unit,
          onCalendar,
        }: {
          inherit description;
          requires = ["pretalx-web.service"];
          after = ["network.target" "pretalx-web.service"];
          wantedBy = ["timers.target"];
          timerConfig = {
            Persistent = true;
            OnCalendar = onCalendar;
            Unit = unit;
          };
        };
      in {
        # About once a month
        pretalx-clearsessions = mkTimer {
          description = "Clear pretalx sessions";
          unit = "pretalx-clearsessions.service";
          onCalendar = "monthly";
        };

        # Once every 15 minutes
        pretalx-runperiodic = mkTimer {
          description = "Run pretalx tasks";
          unit = "pretalx-runperiodic.service";
          onCalendar = "*:0/15";
        };
      };
    };
  };
}
