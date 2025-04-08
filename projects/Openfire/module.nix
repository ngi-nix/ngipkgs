{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.openfire-server;
in
{
  options.services.openfire-server = {
    enable = lib.mkEnableOption "Openfire XMPP server";
    package = lib.mkPackageOption pkgs "openfire" { };

    autoUpdateState = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        When enabled, the state directory will be automatically updated to
        match the installed package version.

        For manually doing this, please refer to the
        [Openfire Upgrade Guide](https://download.igniterealtime.org/openfire/docs/latest/documentation/upgrade-guide.html).
      '';
    };

    servicePort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = ''
        The port on which Openfire should listen for insecure Admin Console access.
      '';
    };

    securePort = lib.mkOption {
      type = lib.types.port;
      default = 9091;
      description = ''
        The port on which Openfire should listen for secure Admin Console access.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to open ports in the firewall for the server.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.package}/opt";
      defaultText = lib.literalExpression ''"''${config.services.openfire.package}/opt"'';
      description = ''
        Where to load readonly data from.
      '';
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/openfire";
      description = ''
        Where to store runtime data (logs, plugins, ...).

        If left at the default, this will be automatically created on server
        startup if it does not already exist. If changed, it is the admin's
        responsibility to make sure that the directory exists and is writeable
        by the `openfire` user.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.openfire = {
      description = "openfire server daemon user";
      home = cfg.stateDir;
      createHome = false;
      isSystemUser = true;
      group = "openfire";
    };
    users.groups.openfire = { };

    systemd.services.openfire-server = {
      path = [ pkgs.rsync ];
      description = "Openfire Server Daemon";
      serviceConfig = lib.mkMerge [
        {
          ExecStart = "${cfg.stateDir}/bin/openfire.sh";
          User = "openfire";
          Group = "openfire";
          Restart = "on-failure";
          WorkingDirectory = cfg.stateDir;
        }
        (lib.mkIf (cfg.stateDir == "/var/lib/openfire") {
          StateDirectory = "openfire";
        })
      ];
      environment.OPENFIRE_HOME = cfg.stateDir;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      # Files under `OPENFIRE_HOME` require read-write permissions for Openfire
      # to work correctly, so we can't directly run it from the nix store.
      #
      # Instead, we need to copy those files into a directory which has proper
      # permissions, but we must only do this once, otherwise we risk
      # ovewriting server state information every time the server is upgraded.
      #
      # As such, if `version` already exists, we assume the rest of
      # the files do as well, and copy nothing.
      preStart =
        let
          # Update Openfire
          # https://download.igniterealtime.org/openfire/docs/latest/documentation/upgrade-guide.html
          updateState = ''
            tmpDir="/tmp/openfire-backup"
            oldVersion=$(cat "${cfg.stateDir}/version")
            newVersion=$(cat "${cfg.dataDir}/version")

            if [ $oldVersion != $newVersion ]; then
              echo "Attempting to update Openfire from $oldVersion to $newVersion"

              # Back up the Openfire state directory
              rsync -a "${cfg.stateDir}/" $tmpDir/

              # Clear old state
              rm -rf "${cfg.stateDir}/*"

              # Install new state
              rsync -a --chmod=u=rwX,go=rX "${cfg.package}/opt/" "${cfg.stateDir}/"

              # Copy old configuration
              # TODO: only backup these directories?
              rsync -a $tmpDir/plugins/ ${cfg.stateDir}/ --exclude=admin
              for dir in conf embedded-db enterprise resources/security; do
                [ -e $tmpDir/$dir ] && rsync -a $tmpDir/$dir ${cfg.stateDir}/;
              done

              rm -rf $tmpDir

              echo "Update complete"
            fi
          '';

          oldStateMessage = ''
            oldVersion=$(cat "${cfg.stateDir}/version")
            newVersion=$(cat "${cfg.dataDir}/version")

            cat <<EOF
            You are trying to run Openfire $newVersion
            with a systemd state directory created by Openfire $oldVersion.
            Until you update the state directory, Openfire will continue using $oldVersion.

            Possible workarounds:
            1. Enable "services.openfire-server.autoUpdateState" to automatically handle this.
            2. Export your data from Openfire $oldVersion,
                clear the state directory, and
                import your data to Openfire $newVersion

                See Openfire documentation for migrating state:
                https://download.igniterealtime.org/openfire/docs/latest/documentation/upgrade-guide.html
            EOF
          '';
        in
        ''
          set -e

          # Install package to state directory (initial run)
          if [ ! -e "${cfg.stateDir}"/version ]; then
            rsync -a --chmod=u=rwX,go=rX "${cfg.package}/opt/" "${cfg.stateDir}/"
          else
            if [ ${toString cfg.autoUpdateState} ]; then
              ${updateState}
            else
              ${oldStateMessage}
            fi
          fi
        '';
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.servicePort
        cfg.securePort
      ];
    };
  };
}
