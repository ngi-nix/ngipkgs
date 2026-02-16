{
  config,
  pkgs,
  lib,
  ...
}:
let
  peerCfg = config.services.peertube;
  cfg = peerCfg.plugins;
in
{
  options.services.peertube.plugins = {
    enable = lib.mkEnableOption ''
      declarative plugin management for PeerTube
    '';

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.peertube;
      defaultText = lib.literalExpression "pkgs.peertube";
      description = "Base PeerTube package to use when using declarative plugin management. This overrides `services.peertube.package`.";
    };

    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression ''
        with pkgs; [
          peertube-plugins.hello-world
        ]
      '';
      description = ''
        List of packages with peertube plugins that should be added.
      '';
    };
  };

  config =
    let
      # Based on let block of Nixpkgs' peertube module
      env = {
        NODE_CONFIG_DIR = "/var/lib/peertube/config";
        NODE_ENV = "production";
        NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
        HOME = "/var/lib/peertube";
      };

      systemCallsList = [
        "@cpu-emulation"
        "@debug"
        "@keyring"
        "@ipc"
        "@memlock"
        "@mount"
        "@obsolete"
        "@privileged"
        "@setuid"
      ];

      cfgService = {
        # Proc filesystem
        ProcSubset = "pid";
        ProtectProc = "invisible";
        # Access write directories
        UMask = "0027";
        # Capabilities
        CapabilityBoundingSet = "";
        # Security
        NoNewPrivileges = true;
        # Sandboxing
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        PrivateMounts = true;
        # System Call Filtering
        SystemCallArchitectures = "native";
      };
      # End Nixpkgs' let block

      mkPluginService =
        configured:
        {
          description = "Management of declaratively specified PeerTube plugins${
            lib.optionalString (!configured) " (initial)"
          }";

          wantedBy = [ "multi-user.target" ];

          environment = env;

          script = lib.getExe (
            pkgs.writeShellApplication {
              name = "peertube-plugins${lib.optionalString (!configured) "-initial"}-script";

              runtimeInputs =
                with pkgs;
                [
                  jq
                  nodejs
                  pnpm_10
                ]
                ++ lib.optionals (!configured) [
                  iproute2
                ];

              text = ''
                set -euo pipefail

                ${lib.optionalString (!configured) ''
                  # Ensure peertube is done configuring & running (HACK)
                  while ! ss -H -t -l -n sport = :${toString peerCfg.listenWeb} | grep -q "^LISTEN.*:${toString peerCfg.listenWeb}"; do
                    sleep 1
                  done
                ''}

                PLUGINS_DIR="${peerCfg.settings.storage.plugins}"

                if [ ! -d "$PLUGINS_DIR/node_modules" ]; then
                  mkdir -p "$PLUGINS_DIR/node_modules"
                fi

                echo '{"dependencies": {}}' > "$PLUGINS_DIR/package.json"

                ${lib.concatMapStringsSep "\n" (pkg: ''
                  PLUGIN_NAME="${pkg.pname}"
                  PLUGIN_PATH="${pkg}/lib/node_modules/$PLUGIN_NAME"

                  echo "Linking plugin: $PLUGIN_NAME"
                  ln -sfn "$PLUGIN_PATH" "$PLUGINS_DIR/node_modules/$PLUGIN_NAME"

                  # Update package.json.
                  # This tells PeerTube that the plugin is installed.
                  jq \
                    --arg name "$PLUGIN_NAME" \
                    --arg path "file:$PLUGIN_PATH" \
                    '.dependencies[$name] = $path' \
                    "$PLUGINS_DIR/package.json" > "$PLUGINS_DIR/package.json.tmp" \
                    && mv "$PLUGINS_DIR/package.json.tmp" "$PLUGINS_DIR/package.json"
                '') cfg.plugins}

                touch ${peerCfg.settings.storage.plugins}.restart
              '';
            }
          );

          serviceConfig = {
            ExecCondition =
              if configured then
                "${pkgs.coreutils}/bin/test -f ${peerCfg.settings.storage.plugins}/nixos-plugins.json"
              else
                "${pkgs.coreutils}/bin/test ! -f ${peerCfg.settings.storage.plugins}/nixos-plugins.json";

            ExecStartPost = "+${pkgs.writeShellScript "peertube-plugins-post" ''
              set -euo pipefail
              if [ -e "${peerCfg.settings.storage.plugins}/.restart" ]; then
                systemctl restart --no-block peertube
                rm ${peerCfg.settings.storage.plugins}/.restart
              fi
            ''}";

            Type = "oneshot";
            WorkingDirectory = peerCfg.package;
            ReadWritePaths = [
              "/var/lib/peertube" # NPM stuff
            ]
            ++ peerCfg.dataDirs;

            # User and group
            User = peerCfg.user;
            Group = peerCfg.group;

            # Sandboxing
            RestrictAddressFamilies = [ ];

            # System Call Filtering
            SystemCallFilter = [
              ("~" + lib.concatStringsSep " " systemCallsList)
              "pipe"
              "pipe2"
            ];
          }
          // cfgService;
        }
        // (
          if configured then { before = [ "peertube.service" ]; } else { after = [ "peertube.service" ]; }
        );
    in
    lib.mkIf (peerCfg.enable && cfg.enable) {
      services.peertube = {
        settings.plugins.index.enabled = false;
        package =
          let
            ov-package = cfg.package.overrideAttrs (previousAttrs: {
              patches = (previousAttrs.patches or [ ]) ++ [
                ./disable-plugin-uninstall.patch
                ./disable-plugin-browsing.patch
                ./plugins-managed-by-nix-message.patch
              ];

              buildInputs = previousAttrs.buildInputs or [ ] ++ [
                pkgs.pnpm_10
              ];

              passthru.debug = mkPluginService false;
            });
          in
          ov-package;
      };

      systemd.services = {
        peertube-plugins-initial = mkPluginService false;
        peertube-plugins = mkPluginService true;
      };
    };

  meta.maintainers = [ ];
}
