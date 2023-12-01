{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkForce
    mkIf
    types
    ;

  cfg = config.services.liberaforms;
  user = "liberaforms";
  group = "liberaforms";
  default_home = "/var/lib/liberaforms";
  default_logs = "/var/log/liberaforms";
in {
  options.services.liberaforms = with types; {
    enable = mkEnableOption "LiberaForms server";

    enablePostgres = mkEnableOption "Postgres database";

    enableNginx = mkEnableOption "Nginx reverse proxy web server";

    enableHTTPS = mkEnableOption "HTTPS for connections to nginx";

    enableDatabaseBackup = mkEnableOption "Cron job for pg_dump";

    package = mkOption {
      type = types.package;
      default = pkgs.liberaforms;
      defaultText = literalExpression "<LiberaForms flake>.packages.<system>.default";
      example = literalExpression "pkgs.liberaforms";
      description = ''
        LiberaForms package to use.
      '';
    };

    domain = mkOption {
      type = types.str;
      description = ''
        Domain for LiberaForms instance.
      '';
      example = "forms.example.org";
      default = "liberaforms.local";
    };

    rootEmail = mkOption {
      type = types.str;
      description = ''
        Email address used for root user of LiberaForms.
      '';
      example = "admin@example.org";
      default = "";
    };

    defaultLang = mkOption {
      type = types.str;
      description = ''
        Default language of LiberaForms.
      '';
      example = "fr";
      default = "en";
    };

    dbHost = mkOption {
      type = types.str;
      description = ''
        Hostname of postgres database.
      '';
      example = "";
      default = "localhost";
    };

    bind = mkOption {
      type = types.str;
      description = ''
        Bind address to be used by gunicorn.
      '';
      example = "0.0.0.0:5000";
      default = "127.0.0.1:5000";
    };

    extraConfig = mkOption {
      type = types.lines;
      description = ''
        Extra configuration for LiberaForms to be appended on the
        configuration.
        see https://gitlab.com/liberaforms/liberaforms/-/blob/develop/dotenv.example
        for all options.
      '';
      default = "";
      example = ''
        ENABLE_REMOTE_STORAGE=True
        MAX_MEDIA_SIZE=512000
      '';
    };

    secretKeyFile = mkOption {
      type = types.str;
      default = "/etc/liberaforms/secret.key";
      description = ''
        A file that contains the server secret for safe session cookies, must be set.
        Created at default location by liberaforms-init script with `openssl rand -base64 32`.
      '';
    };

    dbPasswordFile = mkOption {
      type = types.str;
      default = "/etc/liberaforms/db-password.key";
      description = ''
        A file that contains a password for the liberaforms user in postgres, must be set.
        Created at default location by liberaforms-init script with `openssl rand -base64 32`.
      '';
    };

    cryptoKeyFile = mkOption {
      type = types.str;
      default = "/etc/liberaforms/crypto.key";
      description = ''
        A file that contains a key to encrypt files uploaded to liberaforms.
        Created at default location by liberaforms-init script with `flask cryptokey create`.
      '';
    };

    sessionType = mkOption {
      type = types.str;
      description = ''
        Session management backend (see docs/INSTALL).
      '';
      example = "memcached";
      default = "filesystem";
    };

    flaskEnv = mkOption {
      type = types.str;
      description = ''
        Sets the Flask running mode.
        Can be 'production' or 'development'.
      '';
      example = "development";
      default = "production";
    };

    flaskConfig = mkOption {
      type = types.str;
      description = ''
        Sets the config to use (see config.py).
        Can be 'production' or 'development'.
      '';
      example = "development";
      default = "production";
    };

    workDir = mkOption {
      type = types.str;
      description = ''
        Path to the working directory for LiberaForms.
      '';
      default = default_home;
    };

    workers = mkOption {
      type = types.int;
      default = 3;
      example = 10;
      description = ''
        The number of gunicorn worker processes for handling requests.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/liberaforms 755 liberaforms"
      "d /var/log/liberaforms 755 liberaforms"
      "d /var/backups/liberaforms 755 postgres"
      "d /etc/liberaforms 700 liberaforms"
    ];

    systemd.services.liberaforms = {
      description = "LiberaForms server";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "postgresql.service"];
      requires = ["postgresql.service"];
      restartIfChanged = true;
      path = with pkgs; [postgresql_11 liberaforms-env openssl];

      serviceConfig = {
        Type = "simple";
        PrivateTmp = true;
        ExecStartPre = pkgs.writeScript "liberaforms-init" ''
          #!/bin/sh
          #set -x

          ################################
          ## Generating initial secrets ##
          ################################
          if [ ! -f /etc/liberaforms/secret.key ]; then
            openssl rand -base64 32 > /etc/liberaforms/secret.key
          fi
          if [ ! -f /etc/liberaforms/db-password.key ]; then
            openssl rand -base64 32 > /etc/liberaforms/db-password.key
          fi

          #############################################
          ## Generating liberaforms .env config file ##
          #############################################
          cat > ${cfg.workDir}/.env <<EOF
          # Do not edit this file, it is automatically generated by liberaforms.service.

          SECRET_KEY="$(cat ${cfg.secretKeyFile})"

          BASE_URL = 'https://${cfg.domain}'
          ROOT_USER = '${cfg.rootEmail}'
          DEFAULT_LANGUAGE = '${cfg.defaultLang}'
          TMP_DIR = '/tmp'

          ## Database
          DB_HOST=${cfg.dbHost}
          DB_NAME=liberaforms
          DB_USER=liberaforms
          DB_PASSWORD="$(cat ${cfg.dbPasswordFile})"

          # Maximum valid age for password resets, invitations, ..
          # 86400 seconds = 24h
          TOKEN_EXPIRATION = 604800

          CRYPTO_KEY=$(cat "${cfg.cryptoKeyFile}")

          # Session management (see docs/INSTALL)
          SESSION_TYPE="${cfg.sessionType}"

          # Directory where logs will be saved
          LOG_DIR=${default_logs}

          # see assets/timezones.txt for valid options
          DEFAULT_TIMEZONE="${config.time.timeZone}"

          # FLASK_ENV
          # this sets the Flask running mode
          # can be 'production' or 'development'
          FLASK_ENV="${cfg.flaskEnv}"

          # FLASK_CONFIG
          # this sets the config to use (see config.py)
          # can be 'production' or 'development'
          FLASK_CONFIG="${cfg.flaskConfig}"

          # To modify these options, use services.liberaforms.extraConfig
          # See docs/upload.md for more info
          ENABLE_UPLOADS=True
          TOTAL_UPLOADS_LIMIT='1 GB'
          DEFAULT_USER_UPLOADS_LIMIT='50 MB'
          ENABLE_REMOTE_STORAGE=False
          # 1024 * 500 = 512000 = 500 KiB
          MAX_MEDIA_SIZE=512000
          # 1024 * 1024 * 1.5 = 1572864 = 1.5 MiB
          MAX_ATTACHMENT_SIZE=1572864

          ENABLE_RSS_FEED=False

          # ENABLE_PROMETHEUS_METRICS
          # this activates Prometheus' /metrics route and metrics generation
          ENABLE_PROMETHEUS_METRICS=False

          ENABLE_LDAP=False

          ${cfg.extraConfig}
          EOF

          #####################################
          ## Generating gunicorn config file ##
          #####################################
          cat > ${cfg.workDir}/gunicorn.py <<EOF
          # Do not edit this file, it is automatically generated by liberaforms.service.
          from dotenv import load_dotenv
          load_dotenv(dotenv_path="/var/lib/liberaforms/.env")
          command = '${pkgs.liberaforms-env}/bin/gunicorn'
          bind = '${cfg.bind}'
          workers = ${toString cfg.workers}
          user = '${user}'
          EOF

          ############################################
          ## Setting up working dir for liberaforms ##
          ############################################
          cd ${cfg.workDir}
          ln -sf ${cfg.package}/* .
          # wsgi.py cannot be a symlink because its location determines working dir of gunicorn/flask.
          rm ./wsgi.py
          cp ${cfg.package}/wsgi.py ./wsgi.py
          # After instance creation, ./uploads must remain stateful because it contains uploaded user data.
          if [[ -L "./uploads" ]]; then
            rm -r ./uploads
            cp -rL ${cfg.package}/uploads .
            chmod -R +w uploads
          fi
          # After instance creation, ./logs should also remain stateful
          if [[ -L "./logs" ]]; then
            rm -r ./logs
            mkdir ./logs
            chmod -R +w ./logs
          fi

          #######################################
          ## Generating crypto key for uploads ##
          #######################################
          if [ ! -f /etc/liberaforms/crypto.key ]; then
            cd ${cfg.workDir} ; flask cryptokey create | tr -d '\n' > /etc/liberaforms/crypto.key
            KEY=$(cat "${cfg.cryptoKeyFile}")
            sed -i "s/CRYPTO_KEY=/CRYPTO_KEY=$KEY/" /var/lib/liberaforms/.env
          fi

          #####################################################
          ## Creating database, user, and tables in postgres ##
          #####################################################
          # "${cfg.workDir}/liberaforms/commands/postgres.sh create-db"
          # psql commands from `postgres.sh create-db` script rewritten here to add `-U postgres` and conditionals.
          if ! psql -U postgres -c '\du' | cut -d \| -f 1 | grep -qw liberaforms ; then
            psql -U postgres -c "CREATE USER liberaforms WITH PASSWORD '$(cat ${cfg.dbPasswordFile})'"
          else
            psql -U postgres -c "ALTER USER liberaforms PASSWORD '$(cat ${cfg.dbPasswordFile})';"
          fi
          if ! psql -U postgres -lt | cut -d \| -f 1 | grep -qw liberaforms ; then
            psql -U postgres -c "CREATE DATABASE liberaforms ENCODING 'UTF8' TEMPLATE template0"
          fi
          psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE liberaforms TO liberaforms"
          flask db upgrade
        '';
        ExecStart = "${pkgs.liberaforms-env}/bin/gunicorn -c ${cfg.workDir}/gunicorn.py 'wsgi:create_app()'";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        User = "${user}";
        Group = "${group}";
        WorkingDirectory = "${cfg.workDir}";
        KillMode = "mixed";
        TimeoutStopSec = "5";
      };
    };

    users.users.${user} = {
      group = group;
      home = default_home;
      isSystemUser = true;
    };
    users.groups.${group} = {};

    services.postgresql = mkIf cfg.enablePostgres {
      enable = true;
      package = pkgs.postgresql_11;
      authentication = mkForce ''
        # TYPE  DATABASE         USER            ADDRESS          METHOD
        local   postgres         postgres                         trust
        local   liberaforms      liberaforms                      trust
        host    liberaforms      liberaforms     127.0.0.1/32     trust
        host    liberaforms      liberaforms     ::1/128          trust
      '';
    };

    services.cron = mkIf cfg.enableDatabaseBackup {
      enable = true;
      systemCronJobs = [
        "30 3 * * *   postgres   /run/current-system/sw/bin/pg_dump -U liberaforms liberaforms > /var/backups/liberaforms/db-backup-$(date +\\%Y\\%m\\%d\\%H\\%M).sql"
      ];
    };

    # Based on https://gitlab.com/liberaforms/liberaforms/-/blob/main/docs/nginx.example

    networking = {
      firewall.allowedTCPPorts = mkIf cfg.enableNginx [80 443];
    };

    services.nginx = mkIf cfg.enableNginx {
      enable = true;
      # Send all nginx error and access logs to journald.
      appendHttpConfig = ''
        error_log stderr;
        access_log syslog:server=unix:/dev/log combined;
        types_hash_bucket_size 128; # Clean warning from nginx log
      '';

      virtualHosts."${cfg.domain}" = {
        # Send liberaforms error and access logs to files.
        extraConfig = ''
          access_log /var/log/nginx/liberaforms.access.log;
          error_log /var/log/nginx/liberaforms.error.log notice;
          add_header Referrer-Policy "origin-when-cross-origin";
          add_header X-Content-Type-Options nosniff;
        '';
        locations."/" = {
          # Alias for emailheader could be added here later.
          proxyPass = "http://127.0.0.1:5000";
          extraConfig = ''
            proxy_set_header    X-Forwarded-For $remote_addr;
            proxy_set_header    X-Real-IP   $remote_addr;
            proxy_pass_header   server;
            proxy_set_header Host $host;
          '';
        };
        locations."/static/".extraConfig = ''
          alias ${cfg.workDir}/liberaforms/static/;
        '';
        locations."=/favicon.ico".extraConfig = ''
          alias ${cfg.workDir}/uploads/media/brand/favicon.ico;
        '';
        locations."=/logo.png".extraConfig = ''
          alias ${cfg.workDir}/uploads/media/brand/logo.png;
        '';
        locations."/file/media/".extraConfig = ''
          alias ${cfg.workDir}/uploads/media/;
        '';

        enableACME = mkIf cfg.enableHTTPS true;
        forceSSL = mkIf cfg.enableHTTPS true;
      };
    };
    security.acme = mkIf cfg.enableHTTPS {
      acceptTerms = true;
      defaults.email = "${cfg.rootEmail}";
    };
  };
}
