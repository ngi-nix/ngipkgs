{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nodebb;
  settingsFormat = pkgs.formats.json { };

  # Similar to lib.mapAttrsRecursive but flattens the result
  mapAttrsRecursive' =
    f: set:
    let
      recurse =
        acc: path:
        lib.mapAttrsToList (
          name: value:
          let
            path' = path ++ [ name ];
          in
          if lib.isAttrs value then recurse acc path' value else acc ++ [ (f path' value) ]
        );
    in
    lib.listToAttrs (lib.flatten (recurse [ ] [ ] set));

  configFile =
    let
      # nodebb will try redis if in config.json even if postgres is selected
      excludeIfNot = value: if cfg.settings.database != value then [ value ] else [ ];
      settings = lib.removeAttrs cfg.settings (
        (excludeIfNot "mongo") ++ (excludeIfNot "postgres") ++ (excludeIfNot "redis")
      );
    in
    settingsFormat.generate "config.json" (
      # { a = { b = 0; }; } -> { "a:b" = 0; }
      # https://github.com/NodeBB/NodeBB/blob/3e961257ec0904dbc3b3c64dab3d4cbdffcfbbd7/src/install.js#L177
      settings // (mapAttrsRecursive' (path: lib.nameValuePair (lib.concatStringsSep ":" path)) settings)
    );
in
{
  options.services.nodebb = {
    enable = lib.mkEnableOption "NodeBB";
    package = lib.mkPackageOption pkgs "nodebb" { };

    enableLocalDB = lib.mkEnableOption "a local database for NodeBB";

    user = lib.mkOption {
      type = lib.types.str;
      default = "nodebb";
      description = "The user to run NodeBB under.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "nodebb";
      description = "The group to run NodeBB under.";
    };

    admin = {
      username = lib.mkOption {
        type = lib.types.str;
        example = "admin";
        description = "The admin user username.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        example = "admin@example.com";
        description = "The admin user email address.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.path;
        description = "Path to a file containing the admin user's password.";
      };
    };

    databasePasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the database password.";
    };

    settings = lib.mkOption {
      description = "NodeBB settings that will be written to config.json.";
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options =
          let
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Database host address.";
            };

            portwithDefault =
              default:
              lib.mkOption {
                type = lib.types.port;
                inherit default;
                defaultText = lib.literalMD "default port of selected database";
                description = "Database host port.";
              };

            username = lib.mkOption {
              type = lib.types.str;
              default = "nodebb";
              description = "Database user.";
            };
          in
          {
            url = lib.mkOption {
              type = lib.types.str;
              default = "http://localhost:4567";
              description = "The URL where NodeBB is accessible.";
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 4567;
              description = "The port where NodeBB is accessible.";
            };

            database = lib.mkOption {
              type = lib.types.enum [
                "mongo"
                "postgres"
                "redis"
              ];
              default = "mongo";
              example = "postgres";
              description = "Database type.";
            };

            mongo = {
              inherit host username;

              port = portwithDefault 27017;

              database = lib.mkOption {
                type = lib.types.str;
                default = "nodebb";
                description = "Database name.";
              };
            };

            postgres = {
              inherit host username;

              port = portwithDefault 5432;

              database = lib.mkOption {
                type = lib.types.str;
                default = "nodebb";
                description = "Database name.";
              };

              ssl = lib.mkOption {
                type = lib.types.bool;
                default = false;
                description = "Whether to enable TLS.";
              };
            };

            redis = {
              inherit host;

              port = portwithDefault 6379;

              database = lib.mkOption {
                type = lib.types.int;
                default = 0;
                description = "Database name.";
              };
            };
          };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        systemd.services.nodebb = {
          description = "NodeBB";
          documentation = [ "https://docs.nodebb.org" ];
          after = [
            "system.slice"
            "multi-user.target"
          ];

          environment.CONFIG = "/etc/nodebb/config.json";

          serviceConfig = {
            Type = "forking";
            User = cfg.user;
            Group = cfg.group;
            StateDirectory = "nodebb";
            ConfigurationDirectory = "nodebb";
            WorkingDirectory = "/var/lib/nodebb";
            PIDFile = "/var/lib/nodebb/pidfile";
            ExecStart = "${lib.getExe pkgs.nodejs} loader.js --no-silent";
            Restart = "always";
          };

          preStart = ''
            ${lib.getExe pkgs.rsync} -a --chmod=u+w ${cfg.package}/lib/node_modules/nodebb/ .

            # Cannot copy favicon.ico
            mkdir -p public/uploads/system

            if test ! -f $CONFIG; then
              cp ${configFile} $CONFIG
            else
              # https://stackoverflow.com/a/24904276
              ${lib.getExe pkgs.jq} -s '.[0] * .[1]' $CONFIG ${configFile} > $CONFIG.new
              mv $CONFIG.new $CONFIG
            fi

            databasePasswordKey='."${cfg.settings.database}:password"'
            databasePassword="$(<${cfg.databasePasswordFile})"
            ${lib.getExe pkgs.jq} "$databasePasswordKey = \"$databasePassword\"" $CONFIG > $CONFIG.new
            mv $CONFIG.new $CONFIG

            export NODEBB_ADMIN_USERNAME="${cfg.admin.username}"
            export NODEBB_ADMIN_PASSWORD="$(<${cfg.admin.passwordFile})"
            export NODEBB_ADMIN_EMAIL="${cfg.admin.email}"
            ./nodebb setup "$(<$CONFIG)"
          '';

          wantedBy = [ "multi-user.target" ];
        };

        users = {
          groups.${cfg.group} = { };
          users.${cfg.user} = {
            inherit (cfg) group;
            isSystemUser = true;
          };
        };
      }
      (lib.mkIf (cfg.enableLocalDB && cfg.settings.database == "postgres") {
        systemd.services.nodebb.after = [ "postgresql.service" ];

        services.postgresql = {
          enable = true;
          ensureDatabases = [ "nodebb" ];
          ensureUsers = [
            {
              name = "nodebb";
              ensureDBOwnership = true;
            }
          ];
        };
      })
      (lib.mkIf (cfg.enableLocalDB && cfg.settings.database == "redis") {
        services.nodebb.databasePasswordFile = config.services.redis.servers."nodebb".requirePassFile;

        systemd.services.nodebb.after = [ "redis-nodebb.service" ];

        services.redis.servers."nodebb".enable = true;
      })
    ]
  );
}
