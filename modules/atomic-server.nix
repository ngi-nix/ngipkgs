{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.services.atomic-server;
in
{ 
  options = {
    services.atomic-server = {
      enable = mkEnableOption (lib.mdDoc "Atomic Server");
      description = lib.mdDoc ''
          Configuration for Atomic-server, see <https://docs.atomicdata.dev/atomic-data-overview> for documentation.
        '';
    };
  };
  config = mkIf cfg.enable {
    systemd.services.atomic-server = {
      description = "Atomic Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.atomic-server}/bin/atomic-server";
        DynamicUser = true;
        StateDirectory = "atomic-server";
        CacheDirectory = "atomic-server";
        WorkingDirectory = "/var/lib/atomic-server";
        RuntimeDirectory = "atomic-server";
        RootDirectory = "/run/atomic-server";
        ReadWritePaths = "";
        BindReadOnlyPaths = [
          builtins.storeDir
        ] 
        ++ lib.optional (cfg.settings.tls-cert != null) cfg.settings.tls-cert
        ++ lib.optional (cfg.settings.tls-key != null) cfg.settings.tls-key;
        CapabilityBoundingSet = "";
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        RestrictRealtime = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        UMask = "0066";
        ProtectHostname = true;
      };
    };
  };

  meta.maintainers = [  ];
}
