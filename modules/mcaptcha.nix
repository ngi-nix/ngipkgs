{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib) types;
  cfg = config.services.mcaptcha;
  opt = options.services.mcaptcha;
  settingsFormat = pkgs.formats.toml {};
  filteredSettings = lib.attrsets.filterAttrsRecursive (_path: value: value != null) cfg.settings;
  configFile = settingsFormat.generate "mcaptcha.config.toml" filteredSettings;
in {
  options.services.mcaptcha.enable = lib.mkEnableOption "mCaptcha server";
  options.services.mcaptcha.package = lib.mkPackageOption pkgs "mcaptcha" {};

  options.services.mcaptcha.settings = lib.mkOption {
    type = lib.types.submodule {
      freeformType = settingsFormat.type;

      options.database.name = lib.mkOption {
        type = types.str;
        description = "Applies both when {option}`${opt.database.createLocally}` is set and not.";
        default = "mcaptcha";
      };

      options.database.username = lib.mkOption {
        type = types.nullOr types.str;
        description = "Ignored when {option}`${opt.database.createLocally}`.";
        example = "mcaptcha";
        default = null;
      };

      options.database.hostname = lib.mkOption {
        type = types.nullOr types.str;
        description = "Ignored when {option}`${opt.database.createLocally}`.";
        example = "localhost";
        default = null;
      };

      options.database.port = lib.mkOption {
        type = types.nullOr types.port;
        description = "Ignored when {option}`${opt.database.createLocally}`.";
        example = 5432;
        default = null;
      };

      options.server.port = lib.mkOption {
        type = types.port;
        description = "Web server port.";
        default = 7000;
      };

      options.server.domain = lib.mkOption {
        type = types.str;
        description = "Web server host.";
        default = "localhost";
        example = "example.com";
      };

      options.server.ip = lib.mkOption {
        type = types.str;
        description = "Web server addresses to bind to.";
        default = "127.0.0.1";
        example = "0.0.0.0";
      };
    };

    description = "Extra settings.";
  };

  options.services.mcaptcha.user = lib.mkOption {
    type = types.str;
    description = "User account to run under.";
    default = "mcaptcha";
  };

  options.services.mcaptcha.group = lib.mkOption {
    type = types.str;
    description = "Group for the user mCaptcha runs under.";
    default = "mcaptcha";
  };

  options.services.mcaptcha.database.createLocally = lib.mkOption {
    type = types.bool;
    description = "Whether to create and use a local database instance";
    default = false;
  };

  options.services.mcaptcha.database.passwordFile = lib.mkOption {
    type = types.nullOr types.path;
    description = ''
      Path to a file containing a database password.

      Ignored when {option}`${opt.database.createLocally}`.
    '';
    default = null;
    example = "/run/secrets/mcaptcha/database";
  };

  options.services.mcaptcha.server.cookieSecretFile = lib.mkOption {
    type = types.path;
    description = "Path to a file containing a cookie secret.";
    example = "/run/secrets/mcaptcha/cookie-secret";
  };

  options.services.mcaptcha.captcha.saltFile = lib.mkOption {
    type = types.path;
    description = "Path to a file containing a salt.";
    example = "/run/secrets/mcaptcha/salt";
  };

  options.services.mcaptcha.redis.createLocally = lib.mkOption {
    type = types.bool;
    description = "Whether to create a Redis instance locally.";
    default = false;
  };

  options.services.mcaptcha.redis.host = lib.mkOption {
    type = types.str;
    description = "Ignored when {option}`${opt.redis.createLocally}`.";
    example = "redis.example.com";
  };

  options.services.mcaptcha.redis.port = lib.mkOption {
    type = types.port;
    description = "Applies both when {option}`${opt.redis.createLocally}` is set and not.";
    default = 6379;
  };

  options.services.mcaptcha.redis.user = lib.mkOption {
    type = types.str;
    description = "Ignored when {option}`${opt.redis.createLocally}`.";
    default = "default";
    example = "mcaptcha";
  };

  options.services.mcaptcha.redis.passwordFile = lib.mkOption {
    type = types.path;
    description = ''
      Path to a file containing the Redis server password.

      Ignored when {option}`${opt.redis.createLocally}`.";
    '';
    example = "/run/secrets/mcaptcha/redis-secret";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (!cfg.database.createLocally) -> (cfg.settings.database.username != null);
        message = "If `${opt.database.createLocally}` is not specified, then `${opt.settings.database.username}` must be specified";
      }
      {
        assertion = (!cfg.database.createLocally) -> (cfg.settings.database.port != null);
        message = "If `${opt.database.createLocally}` is not specified, then `${opt.settings.database.port}` must be specified";
      }
      {
        assertion = (!cfg.database.createLocally) -> (cfg.settings.database.hostname != null);
        message = "If `${opt.database.createLocally}` is not specified, then `${opt.settings.database.hostname}` must be specified";
      }
    ];
    services.mcaptcha.settings = {
      # mCaptcha has no support for defaults. Every option must be specified.
      # The module-provided defaults below are based on
      # https://github.com/mCaptcha/mCaptcha/blob/f337ee0643d88723776e1de4e5588dfdb6c0c574/config/default.toml
      debug = lib.mkDefault false;
      source_code = lib.mkDefault "https://github.com/mCaptcha/mCaptcha";
      commercial = lib.mkDefault false;
      allow_demo = lib.mkDefault false;
      allow_registration = lib.mkDefault true;

      server = {
        proxy_has_tls = lib.mkDefault false;
      };

      database = {
        pool = lib.mkDefault 4;
        database_type = lib.mkDefault "postgres";
      };

      captcha = {
        gc = lib.mkDefault 30;
        runners = lib.mkDefault 4;
        queue_length = lib.mkDefault 2000;
        enable_stats = lib.mkDefault true;

        default_difficulty_strategy = {
          avg_traffic_difficulty = lib.mkDefault 50000;
          peak_sustainable_traffic_difficulty = lib.mkDefault 3000000;
          broke_my_site_traffic_difficulty = lib.mkDefault 5000000;
          duration = lib.mkDefault 30;
        };
      };

      redis = {
        pool = lib.mkDefault 4;
      };
    };

    systemd.services.mcaptcha.description = "mCaptcha: a CAPTCHA system that gives attackers a run for their money";

    systemd.services.mcaptcha.script = let
      serverCookieSecret = "export MCAPTCHA_SERVER_COOKIE_SECRET=$(< ${cfg.server.cookieSecretFile})";
      captchaSalt = "export MCAPTCHA_CAPTCHA_SALT=$(< ${cfg.captcha.saltFile})";
      databaseLocalUrl = ''export DATABASE_URL="postgres:///${cfg.settings.database.name}?host=/run/postgresql"'';
      databasePassword = "export MCAPTCHA_DATABASE_PASSWORD=$(< ${cfg.database.passwordFile})";
      redisLocalUrl = ''export MCAPTCHA_REDIS_URL="redis://${cfg.redis.host}:${builtins.toString cfg.redis.port}"'';
      redisRemoteUrl = let
        urlencode = lib.getExe' pkgs.urlencode "urlencode";
      in ''
        redis_user=$(${urlencode} -e userinfo ${lib.escapeShellArg cfg.redis.user})
        redis_pass=$(${urlencode} -e userinfo < ${cfg.redis.passwordFile})
        export MCAPTCHA_REDIS_URL="redis://$redis_user:$redis_pass@${cfg.redis.host}:${builtins.toString cfg.redis.port}"
      '';
      exec = "exec ${lib.getExe cfg.package}";
    in
      lib.concatStringsSep "\n" [
        serverCookieSecret
        captchaSalt
        (
          if cfg.database.createLocally
          then databaseLocalUrl
          else databasePassword
        )
        (
          if cfg.redis.createLocally
          then redisLocalUrl
          else redisRemoteUrl
        )
        exec
      ];

    systemd.services.mcaptcha.environment.MCAPTCHA_CONFIG = builtins.toString configFile;
    systemd.services.mcaptcha.after = ["syslog.target"] ++ lib.optionals cfg.database.createLocally ["postgresql.service"];
    systemd.services.mcaptcha.bindsTo = lib.optionals cfg.database.createLocally ["postgresql.service"];
    systemd.services.mcaptcha.wants = ["network-online.target"];
    systemd.services.mcaptcha.wantedBy = ["multi-user.target"];
    # Settings modeled after https://github.com/mCaptcha/mCaptcha/blob/f337ee0643d88723776e1de4e5588dfdb6c0c574/docs/DEPLOYMENT.md#6-systemd-service-configuration
    systemd.services.mcaptcha.serviceConfig.User = cfg.user;
    systemd.services.mcaptcha.serviceConfig.Type = "simple";
    systemd.services.mcaptcha.serviceConfig.Restart = "on-failure";
    systemd.services.mcaptcha.serviceConfig.RestartSec = 1;
    systemd.services.mcaptcha.serviceConfig.SuccessExitStatus = "3 4";
    systemd.services.mcaptcha.serviceConfig.RestartForceExitStatus = "3 4";
    systemd.services.mcaptcha.serviceConfig.SystemCallArchitectures = "native";
    systemd.services.mcaptcha.serviceConfig.MemoryDenyWriteExecute = true;
    systemd.services.mcaptcha.serviceConfig.NoNewPrivileges = true;
    services.mcaptcha.redis.host = lib.mkIf cfg.redis.createLocally "127.0.0.1";

    users.users."${cfg.user}" = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups."${cfg.group}" = {};

    services.postgresql = lib.mkIf cfg.database.createLocally {
      enable = true;
      ensureDatabases = [cfg.settings.database.name];
      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.mcaptcha = lib.mkIf cfg.redis.createLocally {
      enable = true;
      port = cfg.redis.port;
      extraParams = ["--loadmodule" "${pkgs.mcaptcha-cache}/lib/libcache.so"];
    };
  };
}
