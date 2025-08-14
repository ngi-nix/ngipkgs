{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.kazarma;
in
{
  options.services.kazarma = {
    enable = lib.mkEnableOption "Kazarma";
    package = lib.mkPackageOption pkgs "kazarma" { };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = lib.types.attrsOf lib.types.str;
        options = {
          RELEASE_COOKIE = lib.mkOption {
            type = lib.types.str;
            description = ''
              The Erlang Distribution cookie.  It's recommend to use a long and
              randomly generated string such as: `head -c 40 /dev/random |
              base32`.  It's also recommended to only use alphanumeric
              characters and underscores.
            '';
          };
          HOST = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "Kazarma host address.";
          };
          PORT = lib.mkOption {
            type = lib.types.str;
            default = "4000";
            description = "Kazarma port.";
            apply = toString;
          };
          DATABASE_HOST = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "Database host address.";
          };
          DATABASE_USERNAME = lib.mkOption {
            type = lib.types.str;
            default = "kazarma";
            description = "Database user.";
          };
          DATABASE_PASSWORD = lib.mkOption {
            type = lib.types.str;
            default = "kazarma";
            description = ''
              Database password.  It's recommended to use
              systemd.services.kazarma.environmentFiles instead.
            '';
          };
          DATABASE_DB = lib.mkOption {
            type = lib.types.str;
            default = "kazarma";
            description = "Database name.";
          };
          ACTIVITY_PUB_DOMAIN = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "ActivityPub server domain name.";
          };
          MATRIX_DOMAIN = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "Matrix server domain name.";
          };
          MATRIX_URL = lib.mkOption {
            type = lib.types.str;
            default = "http://127.0.0.1:8008";
            description = "Matrix server URL.";
          };
        };
      };
      default = { };
      description = ''
        Configuration for Kazarma, will be passed as environment variables.
        See <https://docs.kazar.ma/administrator-guide/configuration>.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.kazarma = {
      description = "Kazarma";
      wantedBy = [ "multi-user.target" ];
      environment = {
        RELEASE_TMP = "/tmp";
      }
      // cfg.settings;
      serviceConfig =
        let
          kazarma = lib.getExe cfg.package;
        in
        {
          Type = "exec";
          User = "kazarma";
          Group = "kazarma";
          DynamicUser = true;
          ExecStart = "${kazarma} start";
          ExecStop = "${kazarma} stop";
        };
    };
  };
}
