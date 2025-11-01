{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.icosa-gallery;
in
{
  options.services.icosa-gallery = {
    enable = lib.mkEnableOption "Icosa Gallery";
    package = lib.mkPackageOption pkgs "icosa-gallery" { };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open ports in the firewall.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "The host where Icosa Gallery is accessible.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "The port where Icosa Gallery is accessible.";
      apply = toString;
    };

    enableLocalDB = lib.mkEnableOption "a local database for Icosa Gallery";

    database = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Database host address.";
      };

      username = lib.mkOption {
        type = lib.types.str;
        default = "icosa-gallery";
        description = "Database user.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "icosa-gallery";
        description = "Database name.";
      };
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf lib.types.str;
        options = {
        };
      };
      default = { };
      description = ''
        Configuration for Icosa Gallery, will be passed as environment variables.
        See <https://github.com/icosa-foundation/icosa-gallery/blob/main/django/django_project/settings.py>.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        environment.systemPackages = [ cfg.package ];

        networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

        # https://docs.gunicorn.org/en/stable/deploy.html#systemd
        systemd.services.icosa-gallery = {
          wantedBy = [ "multi-user.target" ];

          environment = {
            POSTGRES_HOST = cfg.database.host;
            POSTGRES_DB = cfg.database.name;
            POSTGRES_USER = cfg.database.username;
            BASE_DIR = "/var/lib/icosa-gallery";
          }
          // cfg.settings;

          serviceConfig = {
            Type = "notify";
            NotifyAccess = "main";
            User = "icosa-gallery";
            Group = "icosa-gallery";
            DynamicUser = true;
            StateDirectory = "icosa-gallery";
            WorkingDirectory = "/var/lib/icosa-gallery";
            ExecStart = "${cfg.package}/opt/icosa-gallery/gunicorn django_project.wsgi:application --bind ${cfg.host}:${cfg.port} --timeout 900";
            ExecReload = "${lib.getExe' pkgs.coreutils "kill"} -s HUP $MAINPID";
            KillMode = "mixed";
            TimeoutStopSec = "5";
            PrivateTmp = true;
            ProtectSystem = "strict";
          };

          preStart =
            let
              icosa-gallery = lib.getExe cfg.package;
            in
            ''
              ${icosa-gallery} migrate
              ${icosa-gallery} collectstatic --noinput
              ${icosa-gallery} run_huey &
            '';
        };
      }
      (lib.mkIf (cfg.enableLocalDB) {
        systemd.services.icosa-gallery.after = [ "postgresql.service" ];

        services.postgresql = {
          enable = true;
          ensureDatabases = [ cfg.database.name ];
          ensureUsers = [
            {
              name = cfg.database.username;
              ensureDBOwnership = true;
            }
          ];
        };
      })
    ]
  );
}
