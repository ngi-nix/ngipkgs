{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit
    (lib)
    types
    mkIf
    mkEnableOption
    mkOption
    mkPackageOption
    ;

  cfg = config.services.vula;
  opt = options.services.vula;
in {
  options.services.vula = with types; {
    enable = mkEnableOption "vula";

    package = mkPackageOption pkgs "vula" {};

    user = mkOption {
      type = str;
      description = "Username of the system user that should own files and services related to vula.";
      default = "vula";
    };

    group = mkOption {
      type = str;
      description = "Group that contains the system user that executes vula.";
      default = "vula";
    };
  };

  config = mkIf cfg.enable {
    users.users."${cfg.user}" = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.users."${cfg.user}-discover" = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.users."${cfg.user}-discover-alt" = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.users."${cfg.user}-publish" = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.users."${cfg.user}-publish-alt" = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.users."${cfg.user}-organize" = {
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups."${cfg.group}" = {};

    environment.systemPackages = [cfg.package];

    systemd.packages = [cfg.package];

    services.dbus.packages = [cfg.package];
  };
}
