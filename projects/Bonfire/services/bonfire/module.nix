{
  config,
  pkgs,
  ...
}@args:
let
  lib = import ../../../../lib/default.nix { inherit (args) lib; };
  service = "bonfire";
  cfg = config.services.${service};
  stateDir = "/var/lib/${service}";

  # Warning(-security/confidentiality):
  # even though secrets are read from files (encrypted or outside the Nix store),
  # they end up in environment variables.
  #
  # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1663
  #
  # ToDo(+security/confidentiality): move entries in stillUnsafeSecrets to secrets
  # whenever they can remain in a file instead of going into an env-var.
  stillUnsafeSecrets = [
    "ENCRYPTION_SALT"
    "MEILI_MASTER_KEY"
    "POSTGRES_PASSWORD"
    "RELEASE_COOKIE"
    "SECRET_KEY_BASE"
    "SIGNING_SALT"
  ];
  secrets = stillUnsafeSecrets;

  elixirFormat = pkgs.formats.elixirConf { elixir = cfg.package.elixir; };
  inherit (elixirFormat.lib) mkAtom mkRaw mkTuple;

in
{
  imports = [
    (lib.modules.importApply ../../../../profiles/nixos/nginx/reverse-proxy.nix {
      inherit service;
      proxyPass = "http://localhost:${toString cfg.settings.SERVER_PORT}";
      proxyWebsockets = true;
    })
  ];

  options.services.bonfire = {
    enable = lib.mkEnableOption "bonfire";
    openFirewall = lib.mkEnableOption ''
      opening the firewall for Bonfire's PUBLIC_PORT.
      This is only necessary if you do not use a reverse-proxy
    '';
    package = lib.mkPackageOption pkgs [ "bonfire" "social" ] { };
    settings = lib.mkOption {
      description = ''
        Configuration for Bonfire, will be passed as environment variables.
        See <https://docs.bonfirenetworks.org/deploy.html>.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            path
            port
            str
          ]);

        options = {
          DB_MIGRATE_INDEXES_CONCURRENTLY = lib.mkEnableOption ''
            disable changes to the database schema when upgrading Bonfire

            Bonfire initialization fails hard with concurrent indexing,
            yet it may be enabled after initial migrations were run
            if you feel lucky.
          '';
          DB_QUERIES_LOG_LEVEL = lib.mkOption {
            # Source: https://www.erlang.org/docs/26/apps/kernel/logger_chapter#log_level
            type = lib.types.enum [
              "emergency"
              "alert"
              "critical"
              "error"
              "warning"
              "notice"
              "info"
              "debug"
            ];
            description = '''';
            default = "warning";
          };
          DISABLE_DB_AUTOMIGRATION = lib.mkEnableOption "disable changes to the database schema when upgrading Bonfire";
          ECTO_IPV6 =
            lib.mkEnableOption ''
              IPv6 when connecting to the PostgreSQL database.

              Do not enable it when connecting through a Unix socket,
              it would make it fail
            ''
            // {
              default = config.networking.enableIPv6 && !(lib.types.path.check cfg.settings.POSTGRES_HOST);
              defaultText = lib.literalExpression "config.networking.enableIPv6 && !(lib.types.path.check config.services.bonfire.settings.POSTGRES_HOST)";
            };
          ENCRYPTION_SALT = lib.mkOption {
            type = lib.types.credential;
            description = ''Encryption salt.'';
          };
          FEDERATE =
            lib.mkEnableOption ''
              federate
            ''
            // {
              default = false;
            };
          HOSTNAME = lib.mkOption {
            type = lib.types.str;
            default = "bonfire.${config.networking.domain}";
            defaultText = lib.literalExpression "bonfire-\${config.networking.domain}";
            description = ''
              Hostname your visitors will use to access bonfire.
            '';
          };
          LANG = lib.mkOption {
            type = lib.types.str;
            default = "en_US.UTF-8";
            description = ''Default language and locale.'';
          };
          LANGUAGE = lib.mkOption {
            type = lib.types.str;
            default = "en_US.UTF-8";
            description = ''Default language and locale.'';
          };
          MAIL_BACKEND = lib.mkOption {
            type = lib.types.enum [
              "smtp"
              "mailgun"
              "none"
            ];
            description = '''';
            default = "none";
          };
          MEILI_MASTER_KEY = lib.mkOption {
            type = with lib.types; nullOr credential;
            description = "Path to the Meilisearch master key.";
            default = null;
          };
          PLUG_SERVER = lib.mkOption {
            type = lib.types.enum [
              "bandit"
              "cowboy"
            ];
            description = ''Webserver to use.'';
            default = "cowboy";
          };
          POSTGRES_HOST = lib.mkOption {
            type = lib.types.str;
            description = ''
              Hostname or Unix socket **directory** to connect to the PostgreSQL database.
            '';
            default = "/run/postgresql";
          };
          POSTGRES_DB = lib.mkOption {
            type = lib.types.str;
            description = ''name of the PostgreSQL database'';
            default = config.users.users.bonfire.name;
            defaultText = lib.literalExpression "config.users.users.bonfire.name";
          };
          POSTGRES_PASSWORD = lib.mkOption {
            type = with lib.types; nullOr credential;
            description = ''
              Password to connect to the PostgreSQL database.
              You do not need to set that when using Unix socket authentification (default).
            '';
            default = null;
          };
          POSTGRES_USER = lib.mkOption {
            type = lib.types.str;
            description = ''role name to connect to the PostgreSQL database'';
            default = config.users.users.bonfire.name;
            defaultText = lib.literalExpression "config.users.users.bonfire.name";
          };
          PUBLIC_PORT = lib.mkOption {
            type = lib.types.port;
            default = 4000;
            description = ''
              Port your visitors will use to access bonfire
              (typically 80 or 443 if using a reverse-proxy).
            '';
          };
          RELEASE_COOKIE = lib.mkOption {
            type = with lib.types; nullOr credential;
            description = ''
              The Erlang Distribution cookie.
              It's recommend to use a long and randomly generated string such as:
              `head -c 40 /dev/random | base32`.
              It's also recommended to only use alphanumeric
              characters and underscores.

              All Bonfire components in your cluster must use the same value.

              If this is `null`, a shared value will automatically be generated
              on startup and used for all components on this machine.
              You do not need to set this except when you spread your cluster
              over multiple hosts.
            '';
          };
          SEARCH_MEILI_INSTANCE = lib.mkOption {
            type = with lib.types; nullOr str;
            description = ''
              Hostname and port of Meilisearch search index.
            '';
            default = null;
          };
          SECRET_KEY_BASE = lib.mkOption {
            type = with lib.types; nullOr credential;
            description = ''
              A file containing a unique base64 encoded secret
              to sign/encrypt cookies and other secrets.
              All Bonfire components in your cluster must use the same value.

              If this is `null`, a shared value will automatically be generated
              on startup and used for all components on this machine.
              You do not need to set this except when you spread your cluster
              over multiple hosts.
            '';
          };
          SIGNING_SALT = lib.mkOption {
            type = lib.types.credential;
            description = ''Signing salt.'';
          };
          SERVER_PORT = lib.mkOption {
            type = lib.types.port;
            default = 4000;
            description = "Bonfire port.";
          };
        };
      };
    };

    elixirSettings = lib.mkOption {
      description = ''
        Runtime Elixir configuration for Bonfire.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType = elixirFormat.type;
        options = {
          ":bonfire" = {
            "Bonfire.Web.Endpoint" = {
              http = {
                ip = lib.mkOption {
                  description = "Listening IP address or Unix socket.";
                  default = mkTuple [
                    0
                    0
                    0
                    0
                    0
                    0
                    0
                    0
                  ];
                  defaultText = lib.literalExpression ''
                    (pkgs.formats.elixirConf { }).lib.mkTuple [0 0 0 0 0 0 0 0]
                  '';
                  example = lib.literalExpression ''
                    (pkgs.formats.elixirConf { }).lib.mkTuple [0 0 0 0 0 0 0 0]
                  '';
                };
              };
            };
          };
          ":tzdata" = {
            ":data_dir" = lib.mkOption {
              internal = true;
              description = ''
                :tzdata needs a writable directory to auto-update
                its TimeZone data periodically.
              '';
              default = mkRaw ''"${stateDir}/tzdata"'';
            };
          };
        };
      };
    };

    meilisearch = {
      enable = lib.mkEnableOption "running a local Meilisearch search engine";
    };

    postgresql = {
      enable = lib.mkEnableOption "running a local PostgreSQL database";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        systemd.services.bonfire = {
          description = "Bonfire";
          after = [
            "network.target"
            "epmd.socket"
          ];
          wantedBy = [ "multi-user.target" ];
          environment =
            # Description: convert to string settings with a simple type.
            lib.mapAttrs (name: value: if lib.isBool value || lib.isInt value then toString value else value) (
              lib.filterAttrs (name: value: !lib.elem name secrets && value != null) (
                cfg.settings
                // {
                  DB_MIGRATE_INDEXES_CONCURRENTLY =
                    if cfg.settings.DB_MIGRATE_INDEXES_CONCURRENTLY then true else "false";
                  # Explanation: behaves like true even when set to false (default), because
                  # ecto_sparkles/lib/schema_migration/auto_migrator.ex
                  # checks only for the existence of this envvar, not its content.
                  DISABLE_DB_AUTOMIGRATION = if cfg.settings.DISABLE_DB_AUTOMIGRATION then true else null;
                }
                // {
                  # Explanation: bonfire_common/lib/runtime_config.ex tests only for the string "false".
                  # HowTo(maint/analyze): cat $(nix -L build --no-link --print-out-paths -f . \
                  #   projects.Bonfire.nixos.tests.basic.nodes.machine.systemd.services.bonfire.environment.BONFIRE_RUNTIME_CONFIG)
                  BONFIRE_RUNTIME_CONFIG = elixirFormat.generate "runtime.exs" cfg.elixirSettings;
                }
                // lib.optionalAttrs (lib.types.path.check cfg.settings.POSTGRES_HOST) {
                  # Explanation: using a Unix socket directly doesn't work without setting PGHOST too.
                  # Issue: https://github.com/elixir-ecto/postgrex/issues/415#issuecomment-2622198966
                  PGHOST = cfg.settings.POSTGRES_HOST;
                }
              )
            );
          serviceConfig = lib.mkMerge (
            [
              {
                User = config.users.users.bonfire.name;
                Group = config.users.groups.bonfire.name;
                ExecStart = lib.getExe (
                  pkgs.writeShellApplication {
                    name = "bonfire-ExecStart";
                    text =
                      # Description: load secrets into env-vars
                      # from ${CREDENTIALS_DIRECTORY}/env.* files.
                      lib.concatMapStringsSep "\n" (
                        secret:
                        lib.optionalString (cfg.settings.${secret} != null) ''
                          ${secret}=''$(systemd-creds cat ${
                            lib.escapeShellArg (cfg.settings.${secret}.name or "env.${secret}")
                          })
                          export ${secret}
                        ''
                      ) stillUnsafeSecrets
                      + ''
                        ${lib.getExe cfg.package} start
                      '';
                  }
                );
                ExecStop = "${lib.getExe cfg.package} stop";
                RuntimeDirectory = [ "bonfire" ];
                StateDirectory = [ "bonfire" ];
                # Explanation: make bonfire puts data uploaded by its users in ${stateDir}/data/
                WorkingDirectory = stateDir;
                Restart = lib.mkDefault "on-failure";
                RestartSec = lib.mkDefault 10;
              }
            ]
            ++ lib.map (
              secret: lib.systemd.serviceConfig.loadCredential "env.${secret}" cfg.settings.${secret}
            ) secrets
          );
        };

        # Explanation: do not let bonfire.service be in charge of epmd.
        services.epmd = {
          enable = true;
        };

        users = {
          users.bonfire = {
            description = "Bonfire";
            group = "bonfire";
            home = stateDir;
            isSystemUser = true;
          };
          groups.bonfire = {
          };
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [ cfg.settings.PUBLIC_PORT ];
        };
      }

      (lib.mkIf cfg.postgresql.enable {
        systemd.services.bonfire = {
          after = [ "postgresql.target" ];
          requires = [ "postgresql.target" ];
        };
        services.postgresql = {
          enable = true;
          ensureDatabases = [ cfg.settings.POSTGRES_DB ];
          extensions = lib.mkIf (cfg.package.mixNixDeps ? "geo_postgis") (
            with config.services.postgresql.package.pkgs; [ postgis ]
          );
          ensureUsers = [
            {
              name = cfg.settings.POSTGRES_USER;
              ensureDBOwnership = true;
              ensureClauses.login = true;
            }
          ];
        };
        systemd.services.postgresql-setup = lib.mkIf (!(lib.types.path.check cfg.settings.POSTGRES_HOST)) {
          path = [
            config.services.postgresql
            pkgs.gnused
            pkgs.replace-secret
          ];
          postStart = ''
            install -m600 ${pkgs.writeText "" ''
              ALTER ROLE ${config.users.users.bonfire.name} WITH ENCRYPTED PASSWORD '@DB_USER_PASSWORD@';
            ''} /run/bonfire/init.sql
            replace-secret @DB_USER_PASSWORD@ $CREDENTIALS_DIRECTORY/env.POSTGRES_PASSWORD /run/bonfire/init.sql
            psql -U postgres --file /run/bonfire/init.sql
            rm /run/bonfire/init.sql
          '';
        };
      })

      (lib.mkIf cfg.nginx.enable {
        services.bonfire = {
          settings = {
            HOSTNAME = lib.mkDefault cfg.nginx.serverName;
            PUBLIC_PORT = lib.mkDefault 443;
          };
          elixirSettings = {
            /*
                FixMe(+optimize +security +co-existence):
                Bonfire does not yet support Unix socket
                Issue: https://github.com/bonfire-networks/bonfire-app/issues/1698

                ":bonfire"."Bonfire.Web.Endpoint"."http" = {
                  "ip" = lib.mkDefault (mkTuple [
                    (mkAtom ":local")
                    "/run/bonfire/socket"
                  ]);
                  # Explanation: avoid crash:
                  # ** (EXIT) shutdown: failed to start child: :ranch_acceptors_sup
                  # ** (EXIT) :badarg
                  "port" = lib.mkDefault 0;
                  "transport_options" = {
                    # Explanation: config/runtime.exs sets :inet6 which is not compatible with a Unix socket
                    "socket_opts" = lib.mkDefault [ ];
                    # Explanation: let the group access the socket.
                    post_listen_callback = lib.mkDefault (
                      # mkRaw "fn (:local, sock) -> File.chmod!(sock, 0o660) end"
                      mkRaw ''fn _ -> File.chmod!("/run/bonfire/socket", 0o660) end''
                    );
                  };
                };
            */
          };
        };
      })

      (lib.mkIf cfg.meilisearch.enable {
        services.meilisearch = {
          enable = true;
        };
        services.bonfire.settings = {
          MEILI_MASTER_KEY = config.services.meilisearch.masterKeyFile;
          SEARCH_MEILI_INSTANCE = "http://${config.services.meilisearch.listenAddress}:${toString config.services.meilisearch.listenPort}";
        };
      })
    ]
  );

  meta = {
    maintainers =
      lib.teams.ngi.members
      ++ (with lib.maintainers; [
        julm
      ]);
    doc = ../../../../manuals/User/Exercise_to/install/services/bonfire.md;
  };
}
