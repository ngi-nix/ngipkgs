{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.atomic-server;
in
{ 
  options = {
    services.atomic-server = {
      enable = mkEnableOption "Enable Atomic Server";
    };
  };
  config = mkIf cfg.enable {
    users.users.atomic-server = {
      isSystemUser = true;
      group = "atomic-server";
    };
    users.groups.atomic-server = {};
    systemd.services.atomic-server = {
      description = "Atomic Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.atomic-server}/bin/atomic-server";
        User = "atomic-server";
        Environment = [
          "ATOMIC_CONFIG_DIR=/var/lib/atomic-server"
          "ATOMIC_DATA_DIR=/var/lib/atomic-server"
        ];
        StateDirectory = "atomic-server";
        CacheDirectory = "atomic-server";
        WorkingDirectory = "/var/lib/atomic-server";
        RuntimeDirectory = "atomic-server";
        RootDirectory = "/run/atomic-server";
        ReadWritePaths = "/var/lib/atomic-server";
        BindReadOnlyPaths = [
          builtins.storeDir
        ];
        CapabilityBoundingSet = "";
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        # RestrictNamespaces = true;
        # PrivateDevices = true;
        # PrivateUsers = true;
        # ProtectClock = true;
        # ProtectControlGroups = true;
        # ProtectHome = true;
        # ProtectKernelLogs = true;
        # ProtectKernelModules = true;
        # ProtectKernelTunables = true;
        # SystemCallArchitectures = "native";
        # SystemCallFilter = [ "@system-service" "~@privileged" ];
        # RestrictRealtime = true;
        # LockPersonality = true;
        # MemoryDenyWriteExecute = true;
        # UMask = "0066";
        # ProtectHostname = true;
      };
    };
  };

  meta.maintainers = [  ];
}
