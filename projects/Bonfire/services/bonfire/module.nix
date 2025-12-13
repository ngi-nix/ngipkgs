{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  cfg = config.services.bonfire;
  stateDir = "/var/lib/bonfire";

  # Warning(security/confidentiality):
  # even though secrets are read from files (out of the Nix store),
  # they end up in environment variables.
  # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1663
  secrets = lib.filter (name: cfg.settings.${name} != null) [
    "ENCRYPTION_SALT"
    "MEILI_MASTER_KEY"
    "POSTGRES_PASSWORD"
    "RELEASE_COOKIE"
    "SECRET_KEY_BASE"
    "SIGNING_SALT"
  ];

  elixirFormat = pkgs.formats.elixirConf { elixir = cfg.package.elixir; };
  inherit (elixirFormat.lib)
    mkAtom
    mkRaw
    mkTuple
    ;
  elixirType =
    let
      elixirType' =
        with lib.types;
        nullOr (oneOf [
          bool
          int
          float
          str
          (attrsOf elixirType')
          (listOf elixirType')
        ])
        // {
          description = "Elixir value";
        };
    in
    elixirType';

in
{
  options.services.bonfire = {
    enable = lib.mkEnableOption "bonfire";
    openFirewall = lib.mkEnableOption ''
      opening the firewall for Bonfire's PUBLIC_PORT.
      This is only necessary if you do not use a reverse-proxy
    '';
    package = lib.mkPackageOption pkgs "bonfire" { };
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
            type = lib.types.path;
            description = '''';
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
            type = with lib.types; nullOr path;
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
          };
          POSTGRES_PASSWORD = lib.mkOption {
            type = with lib.types; nullOr path;
            description = ''
              Password to connect to the PostgreSQL database.
              You do not need to set that when using Unix socket authentification.
            '';
            default = null;
          };
          POSTGRES_USER = lib.mkOption {
            type = lib.types.str;
            description = ''role name to connect to the PostgreSQL database'';
            default = config.users.users.bonfire.name;
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
            type = with lib.types; nullOr path;
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
            type = with lib.types; nullOr path;
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
            type = lib.types.path;
            description = '''';
          };
          SERVER_PORT = lib.mkOption {
            type = lib.types.port;
            default = 4000;
            description = "Bonfire port";
          };
          UPLOAD_LIMIT = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 20;
            description = ''max file upload size in megabytes'';
          };
          UPLOAD_LIMIT_IMAGES = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 5;
            description = '''';
          };
          UPLOAD_LIMIT_VIDEOS = lib.mkOption {
            type = lib.types.ints.unsigned;
            default = 20;
            description = '''';
          };
        };
      };
    };

    runtimeSettings = lib.mkOption {
      description = ''
        Runtime configuration for Bonfire.
        The attributes are serialised to Elixir.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType = elixirFormat.type;
        options = {
          ":bonfire" = {
            "Bonfire.Web.Endpoint" = {
              http = {
                ip = lib.mkOption {
                  type = elixirType;
                  description = "Listening IP address or Unix socket.";
                  default = mkTuple [
                    0
                    0
                    0
                    0
                  ];
                  defaultText = lib.literalExpression ''
                    (pkgs.formats.elixirConf { }).lib.mkTuple [0 0 0 0]
                  '';
                };
              };

            };

          };
          ":tzdata" = {
            ":data_dir" = lib.mkOption {
              type = elixirType;
              internal = true;
              description = ''
                :tzdata needs a writable directory to autoupdate
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

    nginx = lib.mkOption {
      description = ''
        With this option, you can customize an nginx virtual host which already has sensible defaults for `bonfire`.
        Set to `{}` if you do not need any customization to the virtual host.
        If enabled, then by default, the {option}`serverName` is
        `bonfire.''${config.networking.domain}`,
        TLS is active, and certificates are acquired via ACME.
        If this is set to null (the default), no nginx virtual host will be configured.
      '';
      default = null;
      example = lib.literalExpression ''
        {
          enableACME = false;
          useACMEHost = config.networking.domain;
        }
      '';
      # Type of a single virtual host, or null.
      type = lib.types.nullOr (
        lib.types.submodule (
          lib.recursiveUpdate
            (import "${modulesPath}/services/web-servers/nginx/vhost-options.nix" {
              inherit config lib;
            })
            {
              options.serverName = {
                default = "bonfire.${config.networking.domain}";
                defaultText = "bonfire.\${config.networking.domain}";
              };
            }
        )
      );
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
            lib.mapAttrs (name: value: if lib.isBool value || lib.isInt value then toString value else value)
              (
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
                    # HowTo(maint/analyse): cat $(nix -L build --no-link --print-out-paths -f . \
                    #   hydrated-projects.Bonfire.nixos.tests.basic.nodes.machine.systemd.services.bonfire.environment.BONFIRE_RUNTIME_CONFIG)
                    BONFIRE_RUNTIME_CONFIG = elixirFormat.generate "runtime.exs" cfg.runtimeSettings;
                  }
                  // lib.optionalAttrs (lib.types.path.check cfg.settings.POSTGRES_HOST) {
                    # Explanation: using a Unix socket directly doesn't work without setting PGHOST too.
                    # Issue: https://github.com/elixir-ecto/postgrex/issues/415#issuecomment-2622198966
                    PGHOST = cfg.settings.POSTGRES_HOST;
                  }
                )
              );
          serviceConfig = {
            User = config.users.users.bonfire.name;
            Group = config.users.groups.bonfire.name;
            ExecStart = lib.getExe (
              pkgs.writeShellApplication {
                name = "bonfire-ExecStart";
                runtimeInputs = [
                ];
                text =
                  # Explanation: bonfire 1.0.0 assumes all connections needs a password…
                  # but this not the case when using a Unix socket
                  # hence sets a dummy password that will be either overriden or discarded.
                  lib.concatMapStringsSep "\n" (name: ''
                    ${name}=''$(systemd-creds cat "env.${name}")
                    export ${name}
                  '') secrets
                  + ''
                    ${lib.getExe cfg.package} start
                  '';
              }
            );
            ExecStop = "${lib.getExe cfg.package} stop";
            RuntimeDirectory = [ "bonfire" ];
            # Explanation: give access to /run/bonfire/socket
            RuntimeDirectoryMode = "2770";
            StateDirectory = [ "bonfire" ];
            # Explanation: to put data/ into stateDir
            WorkingDirectory = stateDir;
            # ToDo(security/confidentiality): support LoadEncryptedCredential
            LoadCredential = lib.map (name: "env.${name}:${cfg.settings.${name}}") secrets;
            #Restart = lib.mkDefault "on-failure";
            RestartSec = lib.mkDefault 5;
          };
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
        services.postgresql = lib.mkIf cfg.postgresql.enable {
          enable = true;
          ensureDatabases = [ cfg.settings.POSTGRES_DB ];
          extensions = lib.mkIf (lib.elem cfg.package.flavour [ "social" ]) (
            with config.services.postgresql.package.pkgs; [ postgis ]
          );
          authentication = lib.mkIf (cfg.settings.POSTGRES_PASSWORD == null) (
            lib.mkBefore ''
              local ${cfg.settings.POSTGRES_USER} ${cfg.settings.POSTGRES_DB} peer
            ''
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
          postStart = ''
            psql -U postgres -c "ALTER ROLE ${cfg.settings.POSTGRES_USER} WITH LOGIN PASSWORD '$(cat "''${CREDENTIALS_DIRECTORY}/env.POSTGRES_PASSWORD")'";
          '';
          serviceConfig = {
            LoadCredential = lib.map (name: "env.${name}:${cfg.settings.${name}}") secrets;
          };
        };
      })

      (lib.mkIf (cfg.nginx != null) {
        services.bonfire = {
          settings = {
            HOSTNAME = lib.mkDefault cfg.nginx.serverName;
            PUBLIC_PORT = lib.mkDefault 443;
          };
          runtimeSettings = {
            /*
              FixMe(functional/correctness): fails with… "Something went wrong."

              # request_id=GH4lF_e9zCaXOOYAAF-h [info] GET /
              # request_id=GH4lF_e9zCaXOOYAAF-h [error] Please try again or contact the instance admins.
              #     Bonfire.UI.Common.ErrorView.show_error/4 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/error/error_view.ex:138
              #     Phoenix.Template.render_within_layout/4 @ /nix/store/iabpnffpjzb6hh3vlf3csm4k5hh7125k-phoenix_template-1.0.4/src/lib/phoenix/template.ex:197
              #     Phoenix.Template.render_to_iodata/4 @ /nix/store/iabpnffpjzb6hh3vlf3csm4k5hh7125k-phoenix_template-1.0.4/src/lib/phoenix/template.ex:126
              #     anonymous fn/5 in Phoenix.Controller.template_render_to_iodata/4 @ /nix/store/1lwskdd59sz4g3862im55n9j3xjizi8x-phoenix-1.8.1/src/lib/phoenix/controller.ex:1017
              #     :telemetry.span/3 @ (telemetry 1.3.0) telemetry.erl:324
              #     Phoenix.Controller.render_and_send/4 @ /nix/store/1lwskdd59sz4g3862im55n9j3xjizi8x-phoenix-1.8.1/src/lib/phoenix/controller.ex:983

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
                  # This needs ranch >= 2.1 but ranch 1.8.1 is currently used
                  # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1667
                  post_listen_callback = lib.mkDefault (
                    mkRaw "fn _ -> File.chmod!(\"/run/bonfire/socket\", 0o660) end"
                  );
                };
              };
            */
            ":bonfire"."Bonfire.Web.Endpoint"."http" = {
              "transport_options" = {
                # Explanation: config/runtime.exs sets :inet6
                "socket_opts" = lib.mkDefault [ ];
              };
            };
          };
        };
        services.nginx = {
          enable = true;
          virtualHosts.${cfg.nginx.serverName} = lib.mkMerge [
            cfg.nginx
            {
              forceSSL = lib.mkDefault true;
              enableACME = lib.mkDefault true;
              locations."/" = {
                proxyPass = "http://localhost:${toString cfg.settings.SERVER_PORT}";
                # FixMe(+security/confidentiality +performance/time):
                # use a Unix socket whenever Bonfire supports it.
                #proxyPass = "http://unix:/run/bonfire/socket";
                recommendedProxySettings = true;
                proxyWebsockets = true;
              };
            }
          ];
        };
        systemd.services.nginx.serviceConfig.SupplementaryGroups = [
          config.users.groups.bonfire.name
        ];
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

  meta.maintainers = with lib.maintainers; [
    julm
  ];
  # ToDo(usability/learnability): document how to configure and use the service
  #meta.doc = ../bonfire.md;
}

/*
  FixMe(functional/correctness): journalctl -u bonfire
  generated and written: [error: "/", error: "/about", error: "/conduct", error: "/privacy"]
  00:20:04.100 request_id=GH4pvuv31U8ksa8AAF_x [error] Could not generate: /
      anonymous fn/1 in Bonfire.UI.Common.StaticGenerator.generate/2 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:75
      anonymous fn/3 in Enum.frequencies_by/2 @ (elixir 1.18.4) lib/enum.ex:1372
      Enum."-frequencies_by/2-lists^foldl/2-0-"/3 @ (elixir 1.18.4) lib/enum.ex:2546
      Bonfire.UI.Common.StaticGenerator.perform/1 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:18
      Oban.Queue.Executor.perform/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:145
      Oban.Queue.Executor.call/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:77
  00:20:04.106 request_id=GH4pvuv31U8ksa8AAF_x [error] Could not generate: /about
      anonymous fn/1 in Bonfire.UI.Common.StaticGenerator.generate/2 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:75
      anonymous fn/3 in Enum.frequencies_by/2 @ (elixir 1.18.4) lib/enum.ex:1372
      Enum."-frequencies_by/2-lists^foldl/2-0-"/3 @ (elixir 1.18.4) lib/enum.ex:2546
      Bonfire.UI.Common.StaticGenerator.perform/1 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:18
      Oban.Queue.Executor.perform/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:145
      Oban.Queue.Executor.call/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:77
  00:20:04.109 request_id=GH4pvuv31U8ksa8AAF_x [error] Could not generate: /conduct
      anonymous fn/1 in Bonfire.UI.Common.StaticGenerator.generate/2 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:75
      anonymous fn/3 in Enum.frequencies_by/2 @ (elixir 1.18.4) lib/enum.ex:1372
      Enum."-frequencies_by/2-lists^foldl/2-0-"/3 @ (elixir 1.18.4) lib/enum.ex:2546
      Bonfire.UI.Common.StaticGenerator.perform/1 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:18
      Oban.Queue.Executor.perform/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:145
      Oban.Queue.Executor.call/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:77
  00:20:04.119 request_id=GH4pvuv31U8ksa8AAF_x [error] Could not generate: /privacy
      anonymous fn/1 in Bonfire.UI.Common.StaticGenerator.generate/2 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:75
      anonymous fn/3 in Enum.frequencies_by/2 @ (elixir 1.18.4) lib/enum.ex:1372
      Enum."-frequencies_by/2-lists^foldl/2-0-"/3 @ (elixir 1.18.4) lib/enum.ex:2546
      Bonfire.UI.Common.StaticGenerator.perform/1 @ /nix/store/h265q8icw3g2ckxgjc3xfp30qppp4fq8-bonfire_ui_common-0.1.0/src/lib/static_generator/static_generator.ex:18
      Oban.Queue.Executor.perform/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:145
      Oban.Queue.Executor.call/1 @ /nix/store/adxnwgnxgr9b6h9sficlrdl3mbm1grlm-oban-2.20.1/src/lib/oban/queue/executor.ex:77
*/
