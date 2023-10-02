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

  env = lib.attrsets.mapAttrs (_: v: "\"${v}\"") {
    SERVER_NAME = "kbin.localhost, caddy:80"; # Docker
    KBIN_DOMAIN = "kbin.localhost";
    KBIN_TITLE = "/kbin";
    KBIN_DEFAULT_LANG = "en";
    KBIN_FEDERATION_ENABLED = "true";
    KBIN_CONTACT_EMAIL = "contact@kbin.localhost";
    KBIN_SENDER_EMAIL = "noreply@kbin.localhost";
    KBIN_JS_ENABLED = "true";
    KBIN_REGISTRATIONS_ENABLED = "true";
    KBIN_API_ITEMS_PER_PAGE = "25";
    KBIN_STORAGE_URL = "https://kbin.localhost/media";
    KBIN_META_TITLE = "Kbin Lab";
    KBIN_META_DESCRIPTION = "content aggregator and micro-blogging platform for the fediverse";
    KBIN_META_KEYWORDS = "kbin, content agregator, open source, fediverse";
    KBIN_HEADER_LOGO = "false";
    KBIN_FEDERATION_PAGE_ENABLED = "true";
    KBIN_CAPTCHA_ENABLED = "false";

    # RABBITMQ_PASSWORD=!ChangeThisRabbitPass!
    # MESSENGER_TRANSPORT_DSN="amqp://kbin:${RABBITMQ_PASSWORD}@rabbitmq:5672/%2f/messages";
    #MESSENGER_TRANSPORT_DSN=doctrine://default
    MESSENGER_TRANSPORT_DSN = "redis://localhost:6379/messages";

    MAILER_DSN = "mailgun+smtp://postmaster@sandboxxx.mailgun.org:key@default?region=us";
    #MAILER_DSN=smtp://localhost

    LOCK_DSN = "flock";

    APP_ENV = "prod";
    APP_SECRET = "427f5e2940e5b2472c1b44b2d06e0525";
    APP_CACHE_DIR = APP_CACHE_DIR;
    APP_LOG_DIR = APP_LOG_DIR;
    APP_DEBUG = "1";

    POSTGRES_VERSION = "14";
    # FIXME: Symfony (doctrine) does not support unix sockets in DATABASE_URL: https://stackoverflow.com/questions/58743591/symfony-doctrine-how-to-make-doctrine-working-with-unix-socket
    # DATABASE_URL=postgres:///kbin?host=/var/run/postgresql/ \
    DATABASE_URL = DATABASE_URL;
    REDIS_DNS = "redis:///var/run/redis-kbin/redis.sock";

    KBIN_HOME = cfg.stateDir;
  };
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
        locations = {
          "~ ^/index\.php(/|$)".extraConfig = ''
            default_type application/x-httpd-php;
            fastcgi_pass unix:${config.services.phpfpm.pools.kbin.socket};
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            include ${config.services.nginx.package}/conf/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
            fastcgi_param DOCUMENT_ROOT $realpath_root;
            internal;
          '';

          "/".extraConfig = ''
            try_files $uri /index.php$is_args$args;
          '';
        };
        extraConfig = ''
          index index.php;
        '';
      };
    };

    systemd.services."kbin-migrate" = {
      serviceConfig = {
        Type = "oneshot";
      };
      environment = env;
      script = ''
        ${php}/bin/php ${cfg.package}/share/php/kbin/bin/console --no-interaction doctrine:migrations:migrate
      '';
      requires = ["postgresql.service"];
      after = ["postgresql.service"];
    };

    services.redis.servers."kbin" = {
      enable = true;
      user = cfg.user;
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
        error_reporting = E_ALL
      '';

      phpEnv = env;
    };

    systemd.services."phpfpm-kbin" = {
      requires = ["kbin-migrate.service"];
    };
  };
}
