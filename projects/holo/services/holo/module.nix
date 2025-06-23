# NOTES: holod configuration
#   /etc/holod.toml: static configuration that can't change once the daemon starts
#   If this file doesn't exist, the default values will be used
#   example config: https://github.com/holo-routing/holo/blob/master/holo-daemon/holod.toml

{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;
  cfg = config.services.holo-daemon;
  toToml = pkgs.formats.toml { };
  configFile = toToml.generate "holod.toml" cfg.settings;
in
{
  options.services.holo-daemon.enable = mkEnableOption "Holo daemon";
  options.services.holo-daemon.package = mkPackageOption pkgs "holo-daemon" { };

  options.services.holo-daemon.settings = mkOption {
    type = types.submodule {
      freeformType = toToml.type;

      options.user = mkOption {
        type = types.str;
        description = "User for the holo daemon";
        default = "holo";
      };
      options.group = mkOption {
        type = types.str;
        description = "Group for the holo daemon";
        default = "holo";
      };
      # Needs to be writable by @user or @group
      options.database_path = mkOption {
        type = types.str;
        description = "Path to the holo database";
        default = "/var/run/holod/holod.db";
      };
      options.logging = mkOption {
        type = types.submodule {
          freeformType = toToml.type;
          options = {
            journald = mkOption {
              type = types.submodule {
                options = {
                  enabled = mkOption {
                    type = types.bool;
                    description = "Enable or disable journald logging";
                    default = true;
                  };
                };
              };
              description = "Journald logging configuration";
              default = { };
            };
            file = mkOption {
              type = types.submodule {
                options = {
                  enabled = mkOption {
                    type = types.bool;
                    description = "Enable or disable file logging";
                    default = true;
                  };
                  dir = mkOption {
                    type = types.str;
                    description = "Directory for log files";
                    default = "/var/log/";
                  };
                  name = mkOption {
                    type = types.str;
                    description = "Name of the log file";
                    default = "holod.log";
                  };
                };
              };
              description = "File logging configuration";
              default = { };
            };
          };
        };
        description = "Logging configuration for the holo daemon";
        default = { };
      };
      options.plugins = mkOption {
        type = types.submodule {
          freeformType = toToml.type;
          options = {
            grpc = mkOption {
              type = types.submodule {
                options = {
                  enabled = mkOption {
                    type = types.bool;
                    description = "Enable or disable gRPC plugin";
                    default = true;
                  };
                  address = mkOption {
                    type = types.str;
                    description = "gRPC server listening address";
                    default = "[::]:50051";
                  };
                };
              };
              description = "gRPC plugin configuration";
              default = { };
            };
          };
        };
        description = "Plugin configuration for the holo daemon";
        default = { };
      };
    };
    description = "Configuration for the holo daemon";
    default = { };
  };

  config = lib.mkIf cfg.enable {

    users.users = {
      "${cfg.settings.user}" = {
        isSystemUser = true;
        group = cfg.settings.group;
        home = "/var/lib/holod";
        createHome = true;
      };
    };
    users.groups."${cfg.settings.group}" = { };

    environment.etc."holod.toml".source = configFile;

    # Runs service as root user
    systemd.services.holo-daemon = {
      description = "Holo daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/holod";
        Restart = "always";
      };
    };
  };
}
