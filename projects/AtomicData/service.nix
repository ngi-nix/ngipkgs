{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.atomic-server;
  # We need to add these for DirectoriesRS to pick up
  # Since it doesn't pick up the ones set by systemd
  envFile = pkgs.writeText ".env" ''
    ATOMIC_CONFIG_DIR=/var/lib/atomic-server
    ATOMIC_DATA_DIR=/var/lib/atomic-server
    XDG_CACHE_HOME=/var/cache/atomic-server
    ${generators.toINIWithGlobalSection { } { globalSection = cfg.settings; }}
  '';
in
{
  options = {
    services.atomic-server = {
      enable = mkEnableOption "Enable Atomic Server";
      settings = mkOption {
        default = { };
        description = ''
          Atomic Server configuration. Refer to <https://docs.atomicdata.dev/atomicserver/installation#atomicserver-cli-options--env-vars>
          for details on supported values.
          ATOMIC_CONFIG_DIR and ATOMIC_DATA_DIR are set automatically to work with NixOS Modules.
        '';
        example = literalExpression ''
          {
            "ATOMIC_INITALIZE" = "true";
            "ATOMIC_DOMAIN" = "localhost";
            "ATOMIC_REBUILD_INDEX" = "false";
            "ATOMIC_PORT" = "9883";
          }
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    users.users.atomic-server = {
      isSystemUser = true;
      group = "atomic-server";
    };
    users.groups.atomic-server = { };
    systemd.services.atomic-server = {
      description = "Atomic Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.atomic-server}/bin/atomic-server";
        User = "atomic-server";
        EnvironmentFile = envFile;
        StateDirectory = "atomic-server";
        CacheDirectory = "atomic-server";
        RuntimeDirectory = "atomic-server";
        RootDirectory = "/run/atomic-server";
        ReadWritePaths = "/var/lib/atomic-server";
        BindReadOnlyPaths = [
          builtins.storeDir
        ];
        CapabilityBoundingSet = "";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
      };
    };
  };

  meta.maintainers = [ ];
}
