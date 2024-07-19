{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit
    (lib)
    assertMsg
    getAttr
    getExe
    head
    types
    mkIf
    mkEnableOption
    mkOption
    mkOrder
    mkPackageOption
    recursiveUpdate
    ;
  inherit
    (pkgs)
    writeShellApplication
    writeTextFile
    coreutils
    callPackage
    gnugrep
    ;

  cfg = config.services.vula;

  nss-altfiles = callPackage ./nss-altfiles.nix {};

  nssModuleName = "vula";

  logLevelFlag =
    getAttr
    cfg.logLevel
    {
      INFO = "--info";
      WARN = "--quiet";
      DEBUG = "--verbose";
    };

  groupsAreUnique = assertMsg (cfg.operatorsGroup != cfg.systemGroup) "The options `config.services.vula.{systemGroup,operatorsGroup}` must have different values.";

  commonServiceAttrs = {
    serviceConfig = {
      DevicePolicy = "closed";
      Group = cfg.systemGroup;
      LockPersonality = "yes";
      MemoryDenyWriteExecute = "yes";
      NoNewPrivileges = "yes";
      PrivateDevices = "yes";
      PrivateTmp = "yes";
      ProtectControlGroups = "yes";
      ProtectHome = "read-only";
      ProtectKernelLogs = "yes";
      ProtectKernelModules = "yes";
      ProtectKernelTunables = "yes";
      Restart = "always";
      RestartSec = "5s";
      RestrictNamespaces = "yes";
      RestrictRealtime = "yes";
      RestrictSUIDSGID = "yes";
      Slice = "vula.slice";
      StandardError = "journal";
      StandardOutput = "journal";
      Type = "dbus";
    };
    wantedBy = ["multi-user.target"];
  };

  exec-vula-tray = writeShellApplication {
    name = "exec-vula-tray";
    runtimeInputs = [gnugrep coreutils];
    text = ''
      if groups | grep --quiet "\b${cfg.operatorsGroup}\b"; then
        ${getExe cfg.package} tray
      fi
    '';
  };

  vula-tray-desktop-autostart = writeTextFile {
    name = "vula-tray-desktop-file";
    destination = "/etc/xdg/autostart/vula-tray.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Vula tray
      Exec=${getExe exec-vula-tray}
      Icon=${cfg.package}/share/icons/vula_gui_icon.png
    '';
  };

  vula-desktop = writeTextFile {
    name = "vula-desktop-file";
    destination = "/share/applications/vula.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Vula
      Categories=Network
      Exec=${getExe cfg.package} gui
      Icon=${cfg.package}/share/icons/vula_gui_icon.png
    '';
  };
in {
  options.services.vula = {
    enable = mkEnableOption "Enables Vula, \"automatic local network encryption\". The wireguard kernel module is required.";

    package = mkPackageOption pkgs "vula" {};

    userPrefix = mkOption {
      type = types.str;
      description = "Prefix for names of vula system users.";
      default = "vula";
    };

    systemGroup = mkOption {
      type = types.str;
      description = "Group name for vula system users.";
      default = "vula";
    };

    operatorsGroup = mkOption {
      type = types.str;
      description = "Users in this group have full permissions to control vula.";
      default = "vula-ops";
    };

    openFirewall = mkOption {
      type = types.bool;
      description = "Opens ports 5353 and 5354, and enables [option]`${options.networking.firewall.checkReversePath}`.";
      default = false;
    };

    logLevel = mkOption {
      type = types.enum ["INFO" "WARN" "DEBUG"];
      description = "Vula daemons log level.";
      default = "INFO";
      example = "WARN";
    };
  };

  config = mkIf cfg.enable {
    system.nssModules = ["${nss-altfiles}"];
    system.nssDatabases.hosts = mkOrder 0 [nssModuleName];

    users.groups."${assert groupsAreUnique; cfg.systemGroup}" = {};
    users.groups."${assert groupsAreUnique; cfg.operatorsGroup}" = {};

    users.users."${cfg.userPrefix}-discover" = {
      isSystemUser = true;
      group = cfg.systemGroup;
    };

    users.users."${cfg.userPrefix}-publish" = {
      isSystemUser = true;
      group = cfg.systemGroup;
    };

    users.users."${cfg.userPrefix}-organize" = {
      isSystemUser = true;
      group = cfg.systemGroup;
    };

    environment.systemPackages = [
      cfg.package
      vula-tray-desktop-autostart
      vula-desktop
    ];

    services.dbus.packages =
      [
        (writeTextFile {
          name = "vula-dbus.conf";
          destination = "/share/dbus-1/system.d/local.vula.services.conf";
          text = import ./dbus.conf.nix {inherit (cfg) userPrefix operatorsGroup;};
        })
      ]
      ++ (map
        (name:
          writeTextFile {
            name = "local.vula.${name}.service";
            destination = "/share/dbus-1/system-services/local.vula.${name}.service";
            text = ''
              [D-BUS Service]
              Name=local.vula.${name}
              Exec=${coreutils}/bin/false
              User=${cfg.userPrefix}-${name}
              SystemdService=vula-${name}.service
            '';
          })
        ["organize" "discover" "publish"]);

    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [
      5353 # mdns
      5354 # port vula uses wireguard with
    ];

    networking.firewall.checkReversePath = mkIf cfg.openFirewall "loose";

    systemd.services.vula-organize = recursiveUpdate commonServiceAttrs {
      description = "Vula organize service daemon";
      after = ["network.target" "vula-discover.target" "vula-publish.target"];
      serviceConfig.AmbientCapabilities = "CAP_NET_ADMIN";
      serviceConfig.BusName = "local.vula.organize";
      serviceConfig.CapabilityBoundingSet = "CAP_NET_ADMIN";
      serviceConfig.ExecStart = "${getExe cfg.package} ${logLevelFlag} organize";
      serviceConfig.IPAddressDeny = "any";
      serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_NETLINK";
      serviceConfig.StateDirectory = "vula-organize";
      serviceConfig.TasksMax = "24";
      serviceConfig.User = "${cfg.userPrefix}-organize";
    };

    systemd.services.vula-discover = recursiveUpdate commonServiceAttrs {
      description = "Vula discover service daemon";
      after = ["network.target"];
      partOf = ["vula-discover.target"];
      serviceConfig.BusName = "local.vula.discover";
      serviceConfig.ExecStart = "${getExe cfg.package} ${logLevelFlag} discover";
      serviceConfig.IPAddressAllow = "multicast";
      serviceConfig.RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
      serviceConfig.TasksMax = "24";
      serviceConfig.User = "${cfg.userPrefix}-discover";
    };

    systemd.services.vula-publish = recursiveUpdate commonServiceAttrs {
      description = "Vula publish service daemon";
      after = ["network.target"];
      partOf = ["vula-publish.target"];
      serviceConfig.BusName = "local.vula.publish";
      serviceConfig.ExecStart = "${getExe cfg.package} ${logLevelFlag} publish";
      serviceConfig.IPAddressAllow = "multicast";
      serviceConfig.RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX AF_NETLINK";
      serviceConfig.TasksMax = "24";
      serviceConfig.User = "${cfg.userPrefix}-publish";
    };

    systemd.slices.vula.description = "Slice for vula services";
    systemd.slices.vula.before = ["slices.target"];
    systemd.slices.vula.sliceConfig.MemoryMax = "512M";
    systemd.slices.vula.sliceConfig.TasksMax = "72";

    assertions = [
      {
        assertion = (head config.system.nssDatabases.hosts) == nssModuleName;
        message = "Vula name security requires that the first value in `config.system.nssDatabases.hosts` is `\"vula\"`.";
      }
    ];
  };
}
