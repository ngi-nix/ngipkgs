{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit
    (builtins)
    map
    attrNames
    listToAttrs
    ;

  inherit
    (lib)
    options
    types
    modules
    filterAttrs
    mapAttrs
    mapAttrsToList
    optional
    getExe
    strings
    concatLines
    generators
    ;

  inherit
    (generators)
    mkValueStringDefault
    ;

  cfg = config.services.kbin;
  opt = options.services.kbin;

  php = cfg.package.passthru.php;

  secretsNonNull = filterAttrs (_: value: value != null) cfg.secrets;

  # For usage of secrets via systemd credentials:
  credentialIds = attrNames secretsNonNull;
  loadCredentials = mapAttrsToList (name: value: "${name}:${toString value}") secretsNonNull;

  kbin-console = pkgs.writeShellApplication rec {
    name = "kbin-console";
    meta.mainProgram = name;
    text = ''
      ${concatLines (mapAttrsToList (
          name: value: "export ${name}=\"${mkValueStringDefault {} value}\""
        )
        cfg.settings)}

      ${getExe php} ${cfg.package}/bin/console "''$@"
    '';
  };

  kbin-export-secrets = pkgs.writeShellApplication rec {
    name = "kbin-export-secrets";
    meta.mainProgram = name;
    text = ''
      echo """
      ${concatLines (map (
          name: "${name}=\\\"$(<\"$CREDENTIALS_DIRECTORY/${name}\")\\\""
        )
        credentialIds)}
      """ > /tmp/secrets.env
    '';
  };
in {
  options.services.kbin = with types;
  with options; {
    enable = mkEnableOption "Kbin";

    package = mkPackageOption pkgs "kbin" {};

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

    settings = mkOption {
      type = submodule {freeformType = attrsOf str;};
      description = "Enviroment variables used to configure Kbin.";
    };

    secrets = mkOption {
      description = "Paths to files containing secrets, keyed by the respective environment variable.";
      type = submodule {
        freeformType = attrsOf (nullOr path);

        options = listToAttrs (map (
            name: {
              inherit name;
              value = mkOption {
                type = nullOr types.path;
                example = "/run/secrets/kbin/${name}";
                default = null;
                description = "Path to a file that contains the secret `${name}`.";
              };
            }
          ) [
            "APP_SECRET"
            "MERCURE_JWT_SECRET"
            "OAUTH_ENCRYPTION_KEY"
            "OAUTH_PASSPHRASE"
            "POSTGRES_PASSWORD"
            "RABBITMQ_PASSWORD"
            "REDIS_PASSWORD"
          ]);
      };
      default = {};
    };
  };

  config = with modules;
  with options;
    mkIf cfg.enable {
      warnings =
        optional (cfg.settings.APP_ENV == "prod" && cfg.settings.APP_DEBUG != "0")
        "You are running kbin in production mode with debugging enabled. While this may work it is unusual. Please check your configuration.";

      assertions = [
        {
          assertion = cfg.settings ? S3_BUCKET -> cfg.package.passthru.withS3;
          message = "You are setting `${opt.settings}.S3_BUCKET`, but '${cfg.package}' does not support S3. It must be built with the argument `withS3 = true` in order to use S3. Consider overriding.";
        }
      ];

      environment.systemPackages = [kbin-console];

      users = {
        users.${cfg.user} = {
          isSystemUser = true;
          createHome = false;
          group = cfg.group;
        };
        groups.${cfg.group} = {};
      };

      services = {
        kbin.settings = {
          # Kbin
          SERVER_NAME = mkDefault cfg.domain;
          KBIN_DOMAIN = mkDefault cfg.domain;
          KBIN_TITLE = mkDefault "/kbin";
          KBIN_DEFAULT_LANG = mkDefault "en";
          KBIN_FEDERATION_ENABLED = mkDefault "true";
          KBIN_CONTACT_EMAIL = mkDefault "contact@${cfg.domain}";
          KBIN_SENDER_EMAIL = mkDefault "noreply@${cfg.domain}";
          KBIN_STORAGE_URL = mkDefault "https://${cfg.domain}/media";
          KBIN_META_TITLE = mkDefault "Kbin Lab";
          KBIN_META_DESCRIPTION = mkDefault "content aggregator and micro-blogging platform for the fediverse";
          KBIN_META_KEYWORDS = mkDefault "kbin, content agregator, open source, fediverse";
          KBIN_ADMIN_ONLY_OAUTH_CLIENTS = mkDefault "false";

          # Redis
          REDIS_DNS = mkDefault "redis:///var/run/redis-kbin/redis.sock";

          ###> symfony/framework-bundle ###
          APP_ENV = mkDefault "prod";
          APP_SECRET = mkDefault "427f5e2940e5b2472c1b44b2d06e0525";
          ###< symfony/framework-bundle ###

          ###> doctrine/doctrine-bundle ###
          DATABASE_URL = mkDefault "postgresql://${cfg.user}:password@127.0.0.1:5432/${cfg.user}";
          ###< doctrine/doctrine-bundle ###

          ###> symfony/messenger ###
          MESSENGER_TRANSPORT_DSN = mkDefault "redis:///var/run/redis-kbin/redis.sock";
          ###< symfony/messenger ###

          ###> nelmio/cors-bundle ###
          CORS_ALLOW_ORIGIN = mkDefault "'^https?://(${cfg.domain}|127\.0\.0\.1)(:[0-9]+)?$'";
          ###< nelmio/cors-bundle ###

          APP_CACHE_DIR = mkDefault "/tmp";
          APP_LOG_DIR = mkDefault "/var/log/kbin";
          APP_DEBUG = mkDefault "0";
        };

        nginx = {
          enable = true;
          virtualHosts."${cfg.domain}" = let
            securityHeaders = ''
              add_header X-Frame-Options "DENY" always;
              add_header X-XSS-Protection "1; mode=block" always;
              add_header X-Content-Type-Options "nosniff" always;
              add_header Referrer-Policy "no-referrer" always;
              add_header X-Download-Options "noopen" always;
              add_header X-Permitted-Cross-Domain-Policies "none" always;
            '';
          in {
            root = "${cfg.package}/public";

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

              "/" = {
                index = "index.php";
                extraConfig = ''
                  try_files $uri /index.php$is_args$args;
                '';
              };

              "/favicon.ico".extraConfig = ''
                access_log off;
                log_not_found off;
              '';

              "/robots.txt".extraConfig = ''
                access_log off;
                log_not_found off;
              '';

              "~ ^/media/cache/resolve".extraConfig = ''
                expires 1M;
                access_log off;
                add_header Cache-Control "public";
                ${securityHeaders}
                try_files $uri $uri/ /index.php?$query_string;
              '';

              "~* .(js|webp|jpg|jpeg|gif|png|css|tgz|gz|rar|bz2|doc|pdf|ppt|tar|wav|bmp|rtf|swf|ico|flv|txt|woff|woff2|svg)$".extraConfig = ''
                expires 30d;
                add_header Pragma "public";
                add_header Cache-Control "public";
                ${securityHeaders}
              '';

              "~ /\\.(?!well-known).*".extraConfig = ''
                deny all;
              '';
            };

            extraConfig = ''
              index index.php;

              charset utf-8;

              # Don't leak powered-by
              fastcgi_hide_header X-Powered-By;

              ${securityHeaders}

              client_max_body_size 20M; # Max size of a file that a user can upload

              location ~ \.php$ {
                return 404;
              }
            '';
          };
        };

        redis.servers."kbin" = {
          inherit (cfg) user;
          enable = true;
        };

        phpfpm.pools.kbin = {
          user = cfg.user;
          group = cfg.group;
          settings = {
            "listen.owner" = config.services.nginx.user;
            "listen.group" = config.services.nginx.group;
            "listen.mode" = mkDefault "0600";
            "pm" = mkDefault "dynamic";
            "pm.max_children" = mkDefault 60;
            "pm.start_servers" = mkDefault 10;
            "pm.min_spare_servers" = mkDefault 5;
            "pm.max_spare_servers" = mkDefault 10;
          };
          phpPackage = php;

          phpOptions = ''
            error_log = stderr
            log_errors = on
            error_reporting = E_ALL

            upload_max_filesize = 8M
            post_max_size = 8M
            memory_limit = 256M

            opcache.enable=1
            opcache.enable_cli=1
            opcache.memory_consumption=512
            opcache.interned_strings_buffer=128
            opcache.max_accelerated_files=100000
            opcache.jit_buffer_size=500M
          '';

          phpEnv = mapAttrs (_: v: "\"${v}\"") (filterAttrs (_: v: v != "") cfg.settings);
        };
      };

      systemd.services = {
        kbin-migrate = {
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${getExe kbin-console} --no-interaction doctrine:migrations:migrate";

            ExecStartPre = getExe kbin-export-secrets;
            EnvironmentFile = "-/tmp/secrets.env";
            LoadCredential = loadCredentials;
            PrivateTmp = true;
            User = cfg.user;
            Group = cfg.group;

            LogsDirectory = "kbin";
            LogsDirectoryMode = "0770";
          };

          requires = ["postgresql.service" "redis-kbin.service"];
          after = ["postgresql.service" "redis-kbin.service"];
        };

        phpfpm-kbin = {
          requires = ["kbin-migrate.service"];
          after = ["kbin-migrate.service"];

          serviceConfig = {
            ExecStartPre = getExe kbin-export-secrets;
            EnvironmentFile = "-/tmp/secrets.env";
            LoadCredential = loadCredentials;
            PrivateTmp = true;
            StateDirectory = "kbin";
            StateDirectoryMode = "0770";
            LogsDirectory = "kbin";
            LogsDirectoryMode = "0770";
            Group = cfg.group;
          };
        };
      };
    };
}
