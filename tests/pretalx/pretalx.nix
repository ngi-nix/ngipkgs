{
  pkgs,
  ngipkgsModule,
  ...
}:
with pkgs;
with lib; let
  password = "SummerOfNix2023";
in {
  name = "pretalx tests";

  nodes = {
    server = {config, ...}: let
      cfg = config.services.pretalx;
    in {
      imports = [../../modules/pretalx.nix ngipkgsModule];

      networking.firewall.allowedTCPPorts = [cfg.port 80];

      environment.systemPackages = [cfg.package];

      services = {
        pretalx = {
          enable = true;
          package = pretalx;
          site = {
            csp = "x";
            csp_img = "y";
          };
          database = {
            backend = "mysql";
            user = "pretalx";
            name = mkIf (cfg.database.backend == "sqlite3") "/tmp/pretalx.db";
            host =
              mkIf (cfg.database.backend == "mysql")
              "/var/run/mysqld/mysqld.sock";
            passwordFile = writeText "pretalx-database-password" "pretalx";
          };
          redis = {
            enable = true;
            locationFile =
              writeText "pretalx-redis"
              "unix:///run/redis-pretalx/redis.sock?db=0";
          };
          celery = {
            enable = true;
            backendFile = writeText "pretalx-celery-backend" "redis+socket:///run/redis-pretalx/redis.sock?virtual_host=1";
            brokerFile = writeText "pretalx-celery-broker" "redis+socket:///run/redis-pretalx/redis.sock?virtual_host=2";
          };

          init = {
            admin = {
              email = "pretalx@localhost";
              passwordFile = writeText "pretalx-admin-password" password;
            };
            organiser = {
              name = "NGI Packages";
              slug = "ngipkgs";
            };
          };
          mail.enable = false;
          # mail.passwordFile = writeText "pretalx-admin-password" password;
        };

        redis.servers."pretalx" = mkIf cfg.redis.enable {
          enable = true;
          user = cfg.user;
        };

        postgresql = mkIf (cfg.database.backend == "postgresql") {
          enable = true;
          authentication = "local all all trust";
          ensureUsers = [
            {
              name = cfg.database.user;
              ensurePermissions."DATABASE \"${cfg.database.name}\"" = "ALL PRIVILEGES";
            }
          ];
          ensureDatabases = [cfg.database.name];
        };

        mysql = mkIf (cfg.database.backend == "mysql") {
          enable = true;
          package = mysql;
          ensureUsers = [
            {
              name = cfg.database.user;
              ensurePermissions."${cfg.database.name}.*" = "ALL PRIVILEGES";
            }
          ];
          ensureDatabases = [cfg.database.name];
        };

        nginx = {
          enable = true;
          recommendedTlsSettings = true;
          recommendedOptimisation = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;
          virtualHosts."localhost" = {
            enableACME = false;
            forceSSL = false;
            locations."/".proxyPass = "http://localhost:${builtins.toString cfg.port}";
          };
        };
      };
    };
  };

  testScript = {nodes, ...}: let
    port = builtins.toString nodes.server.services.pretalx.port;
  in ''
    start_all()

    with subtest("pretalx-web"):
        # NOTE: We cannot use `server.wait_for_unit("pretalx-web.service")`
        # because the systemd service will change state to "active",
        # before pretalx is actually ready to serve requests, leading
        # to failure. pretalx/Django does not support the sd_notify
        # protocol as of 2023-08-11, which could be used to notify
        # systemd about the state of the webserver.
        server.wait_for_open_port(${port})

        server.execute("pretalx create_test_event")

        # NOTE: "democon" is the slug of the event created by
        # `pretalx create_test_event`.
        server.succeed("curl --fail --connect-timeout 10 http://localhost:${port}/democon")
  '';
}
