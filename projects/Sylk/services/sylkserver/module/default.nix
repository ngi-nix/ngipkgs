{
  config,
  pkgs,
  lib,
  ...
}@args:

let
  cfg = config.services.sylkserver;
  settingsFormat = pkgs.formats.ini { };

  configDir = pkgs.runCommand "sylkserver-config-dir" { } ''
    mkdir -p $out

    ${lib.concatMapStringsSep "\n" (name: ''
      cat > $out/${name}.ini <<EOF
      ${lib.generators.toINI { } cfg.settings.${name}}
      EOF
    '') (lib.attrNames cfg.settings)}
  '';

  logsDir = cfg.settings.config.Server.trace_dir;
  spoolDir = cfg.settings.config.Server.spool_dir;
  transferDir = cfg.settings.conference.Conference.file_transfer_dir;
  screensharingDir = cfg.settings.conference.Conference.screensharing_images_dir;
in

{
  options = {
    services.sylkserver = {
      enable = lib.mkEnableOption "the SylkServer SIP/XMPP/WebRTC Application Server";
      package = lib.mkPackageOption pkgs "sylkserver" { };
      debug = lib.mkEnableOption "verbose logging";

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open ports in the firewall for SylkServer.";
      };

      user = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "sylkserver";
        description = "User account under which SylkServer runs.";
      };

      group = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "sylkserver";
        description = "Group under which SylkServer runs.";
      };

      # See configuration samples for options
      # e.g. https://github.com/AGProjects/sylkserver/blob/master/config.ini.sample
      settings = lib.mkOption {
        type = lib.types.submodule {
          options = {
            config = lib.mkOption {
              type = lib.types.submodule (import ./config-modules/config.nix args);
              default = { };
              description = "Main SylkServer configuration.";
            };
            conference = lib.mkOption {
              type = lib.types.submodule (import ./config-modules/conference.nix args);
              default = { };
              description = "Conference application configuration.";
            };
            auth = lib.mkOption {
              type = lib.types.submodule {
                freeformType = settingsFormat.type;
                options = { };
              };
              default = { };
              description = "Authentication configuration.";
            };
            playback = lib.mkOption {
              type = lib.types.submodule {
                freeformType = settingsFormat.type;
                options = { };
              };
              default = { };
              description = "Playback application configuration.";
            };
            webrtcgateway = lib.mkOption {
              type = lib.types.submodule {
                freeformType = settingsFormat.type;
                options = { };
              };
              default = { };
              description = "WebRTC gateway configuration.";
            };
            xmppgateway = lib.mkOption {
              type = lib.types.submodule (import ./config-modules/xmppgateway.nix args);
              default = { };
              description = "XMPP gateway configuration.";
            };
            ircconference = lib.mkOption {
              type = lib.types.submodule {
                freeformType = settingsFormat.type;
                options = { };
              };
              default = { };
              description = "IRC conference configuration.";
            };
          };
        };
        default = { };
        description = "SylkServer configuration files.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # TODO: dynamic user?
    # there were some issues with using a dynamic user (tied to uid and gid)
    # that may warrant patching the software
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      description = "SylkServer service user";
      isSystemUser = true;
      group = cfg.group;
    };

    systemd.services.sylkserver = {
      description = "SylkServer SIP/XMPP/WebRTC Application Server";
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = toString [
          (lib.getExe' cfg.package "sylk-server")
          (lib.optionalString cfg.debug "--debug")
          "--no-fork"
          "--config-dir ${configDir}"
        ];
        StateDirectory = [
          "sylkserver"
          "sylkserver/file_transfer"
          "sylkserver/screensharing_images"
        ];
        LogsDirectory = [
          "sylkserver"
        ];
        BindPaths = [
          "%S/sylkserver/file_transfer:${transferDir}"
          "%S/sylkserver/screensharing_images:${screensharingDir}"
          "%S/sylkserver:${spoolDir}"
          "%L/sylkserver:${logsDir}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
      wantedBy = [
        "multi-user.target"
      ];
      after = [
        "network.target"
        "systemd-tmpfiles-setup.service"
      ];
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.settings.config.SIP.local_tcp_port
        cfg.settings.config.SIP.local_tls_port
        cfg.settings.config.WebServer.local_port
        cfg.settings.xmppgateway.general.local_port
      ];
      allowedUDPPorts = [
        cfg.settings.config.SIP.local_udp_port
      ];
      allowedTCPPortRanges =
        let
          portRangeRTP = lib.pipe cfg.settings.config.RTP.port_range [
            (lib.splitString ":")
            (ports: {
              from = lib.elemAt ports 0;
              to = lib.elemAt ports 1;
            })
          ];
        in
        [
          portRangeRTP
        ];
    };
  };
}
