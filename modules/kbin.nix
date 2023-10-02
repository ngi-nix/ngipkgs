{
  config,
  lib,
  options,
  pkgs,
  ...
}:
with builtins;
with lib; let
  cfg = config.services.kbin;
  opt = options.services.kbin;

  # TODO: move this to some better place
  php = pkgs.php.withExtensions (
    {
      enabled,
      all,
    }:
      enabled ++ [all.amqp all.redis]
  );

  DATABASE_URL = "postgresql://kbin:kbin@127.0.0.1:5432/kbin";
  APP_CACHE_DIR = "/tmp";
  APP_LOG_DIR = "/tmp/log";
in {
  options.services.kbin = with types; {
    enable = mkEnableOption "Kbin";

    package = mkPackageOption pkgs "kbin-frontend" {};

    user = mkOption {
      type = str;
      default = "kbin";
      description = "User to run Kbin as.";
    };

    group = mkOption {
      type = str;
      default = "kbin";
      description = "Primary group of the user running Kbin.";
    };

    domain = mkOption {
      type = types.str;
      default = "localhost";
      example = "forum.example.com";
      description = "Domain to serve on.";
    };

    stateDir = mkOption {
      type = types.path;
      default = "/var/lib/kbin";
      description = "Home directory for writable storage";
    };

    extraConfig = mkOption {
      type = attrs;
      description = ''
        Extra configuration to be merged with the generated Kbin configuration file.
      '';
      default = {};
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    users.users."${cfg.user}" = {
      isSystemUser = true;
      createHome = false;
      group = cfg.group;
    };

    users.groups."${cfg.group}" = {};

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.domain}" = {
        root = "${cfg.package}/share/php/kbin/public";
        locations."~ ^/index\.php(/|$)".extraConfig = ''
          fastcgi_pass unix:${config.services.phpfpm.pools.kbin.socket};
          fastcgi_index index.php;
        '';
        extraConfig = ''
          index index.php;
          # include ${cfg.package}/share/php/kbin/.nginx.conf;
        '';
      };
    };

    systemd.services."kbin-migrate" = {
      serviceConfig = {
        Type = "oneshot";
      };
      environment = {
        # FIXME: Symfony (doctrine) does not support unix sockets in DATABASE_URL: https://stackoverflow.com/questions/58743591/symfony-doctrine-how-to-make-doctrine-working-with-unix-socket
        # DATABASE_URL=postgres:///kbin?host=/var/run/postgresql/ \
        DATABASE_URL = DATABASE_URL;
        APP_LOG_DIR = APP_LOG_DIR;
        APP_CACHE_DIR = APP_CACHE_DIR;
      };
      script = ''
        ${php}/bin/php ${cfg.package}/share/php/kbin/bin/console --no-interaction doctrine:migrations:migrate
      '';
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };

    services.phpfpm.pools.kbin = {
      user = cfg.user;
      settings = {
        "listen.owner" = config.services.nginx.user;
        "listen.group" = config.services.nginx.group;
        "listen.mode" = "0600";
        "pm" = mkDefault "dynamic";
        "pm.max_children" = mkDefault 10;
        "pm.max_requests" = mkDefault 500;
        "pm.start_servers" = mkDefault 2;
        "pm.min_spare_servers" = mkDefault 1;
        "pm.max_spare_servers" = mkDefault 3;
      };
      phpOptions = ''
        error_log = syslog
        log_errors = on
      '';
      phpEnv = {
        APP_CACHE_DIR = APP_CACHE_DIR;
        APP_LOG_DIR = APP_LOG_DIR;
        APP_DEBUG = "1";

        DATABASE_URL = DATABASE_URL;
      };
    };

    systemd.services."phpfpm-kbin" = {
      requires = ["kbin-migrate.service"];
    };
  };
}
