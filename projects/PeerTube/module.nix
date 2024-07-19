{
  config,
  pkgs,
  lib,
  ...
}: let
  peerCfg = config.services.peertube;
  cfg = peerCfg.plugins;
in {
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
      default = [];
      example = lib.literalExpression ''
        with pkgs; [
          peertube-plugin-hello-world
        ]
      '';
      description = ''
        List of packages with peertube plugins that should be added.
      '';
    };
  };

  config = let
    # Based on let block of Nixpkgs' peertube module
    env = {
      NODE_CONFIG_DIR = "/var/lib/peertube/config";
      NODE_ENV = "production";
      NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";
      NPM_CONFIG_CACHE = "/var/cache/peertube/.npm";
      NPM_CONFIG_PREFIX = peerCfg.package;
      HOME = peerCfg.package;
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

    mkPluginService = configured:
      {
        description = "Management of declaratively specified PeerTube plugins${
          lib.optionalString (!configured) " (initial)"
        }";

        wantedBy = ["multi-user.target"];

        environment = env;

        script = let
          nixosPluginsJson = pkgs.writeText "nixos-plugins.json" (
            builtins.toJSON (map (plugin: plugin.pname) cfg.plugins)
          );
        in
          lib.getExe (
            pkgs.writeShellApplication {
              name = "peertube-plugins${lib.optionalString (!configured) "-initial"}-script";

              runtimeInputs = with pkgs;
                [
                  jq
                  nodejs
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

                if [ -e "${peerCfg.settings.storage.plugins}/package.json" ]; then
                  packages_hash_pre="$(sha256sum ${peerCfg.settings.storage.plugins}/package.json)"
                else
                  packages_hash_pre=""
                fi

                # To install packages offline from their caches, configure NPM to behave
                npmfun="$(mktemp -d)"
                export NPM_CONFIG_USERCONFIG="$npmfun"/.npmrc
                npm config set offline true
                npm config set progress false

                ${lib.concatMapStrings (plugin: ''
                    npm config set cache ${plugin.npmDeps or "/no-npm-deps"}
                    echo "Running installer for ${plugin}/lib/node_modules/${plugin.pname}"
                    node ~/dist/scripts/plugin/install.js -p ${plugin}/lib/node_modules/${plugin.pname}
                  '')
                  cfg.plugins}

                rm -r "$npmfun"

                if [ -e "${peerCfg.settings.storage.plugins}/nixos-plugins.json" ]; then
                  for plugin in $(jq --slurp --raw-output '.[0] - .[1] | .[]' ${peerCfg.settings.storage.plugins}/nixos-plugins.json ${nixosPluginsJson}); do
                    # ignore trailing newline
                    [ -z "$plugin" ] && continue
                    echo "Removing plugin $plugin (even on success, a (wrong) error message is returned)"
                    node ~/dist/scripts/plugin/uninstall.js -n "$plugin"
                  done
                fi

                ln -sf ${nixosPluginsJson} ${peerCfg.settings.storage.plugins}/nixos-plugins.json

                packages_hash_post="$(sha256sum ${peerCfg.settings.storage.plugins}/package.json)"
                [ "$packages_hash_pre" = "$packages_hash_post" ] || touch ${peerCfg.settings.storage.plugins}/.restart
              '';
            }
          );

        serviceConfig =
          {
            ExecCondition =
              if configured
              then "${pkgs.coreutils}/bin/test -f ${peerCfg.settings.storage.plugins}/nixos-plugins.json"
              else "${pkgs.coreutils}/bin/test ! -f ${peerCfg.settings.storage.plugins}/nixos-plugins.json";

            ExecStartPost = "+${pkgs.writeShellScript "peertube-plugins-post" ''
              set -euo pipefail
              if [ -e "${peerCfg.settings.storage.plugins}/.restart" ]; then
                systemctl restart --no-block peertube
                rm ${peerCfg.settings.storage.plugins}/.restart
              fi
            ''}";

            Type = "oneshot";
            WorkingDirectory = peerCfg.package;
            ReadWritePaths =
              [
                "/var/lib/peertube" # NPM stuff
              ]
              ++ peerCfg.dataDirs;

            # User and group
            User = peerCfg.user;
            Group = peerCfg.group;

            # Sandboxing
            RestrictAddressFamilies = [];

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
        if configured
        then {before = ["peertube.service"];}
        else {after = ["peertube.service"];}
      );
  in
    lib.mkIf (peerCfg.enable && cfg.enable) {
      services.peertube.package = cfg.package.overrideAttrs (oa: {
        # yarn can't handle npm caches, and we can't build npm packages with our yarn tooling
        # Working on getting declarative plugin management into upstream to avoid this: https://github.com/Chocobozzz/PeerTube/issues/6428
        postPatch =
          (oa.postPatch or "")
          + ''
            substituteInPlace server/core/lib/plugins/yarn.ts \
              --replace-fail 'yarn ''${command}' 'npm --offline ''${command}'
          '';
      });

      systemd.services = {
        peertube-plugins-initial = mkPluginService false;
        peertube-plugins = mkPluginService true;
      };
    };

  meta.maintainers = [];
}
