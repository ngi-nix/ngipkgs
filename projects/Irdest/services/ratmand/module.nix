{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.ratmand;

  # Convert `cfg.settings` to arguments for `ratmand generate` to generate the config
  # file.
  configPatchArgs =
    lib.concatLists (
      (lib.mapAttrsToList (
        section: sectionAttrs:
        lib.mapAttrsToList (
          key: value:
          ''--patch "${section}/${key}=${
            if lib.isBool value then lib.boolToString value else toString value
          }"''
        ) sectionAttrs
      ) (cfg.settings // { ratmand = lib.removeAttrs (cfg.settings.ratmand or { }) [ "peers" ]; }))
    )
    ++ lib.map (peer: ''--add-peer "${peer}"'') cfg.settings.ratmand.peers;

  configFile = pkgs.runCommand "ratmand-config" { } ''
    ${lib.getExe' cfg.package "ratmand"} --config "$out" generate ${lib.concatStringsSep " " configPatchArgs}
  '';
in
{
  options.services.ratmand = {
    enable = lib.mkEnableOption "ratmand, a decentralised peer-to-peer packet router";

    package = lib.mkPackageOption pkgs "ratman" { };

    settings = lib.mkOption {
      type = lib.types.submodule (
        { config, ... }:
        {
          freeformType =
            with lib.types;
            attrsOf (
              attrsOf (oneOf [
                str
                bool
                int
              ])
            );
          options = {
            ratmand.peers = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              example = [
                "inet:hyperion.kookie.space:5860"
                "inet:hub.irde.st:5860"
              ];
              description = ''
                Initial peers. The format is: `<driver>:<hostname/ip address>:[<port>]`.
              '';
            };
          };
        }
      );
      default = { };
      example = {
        ratmand = {
          accept_unknown_peers = true;
          peers = [
            "inet:hyperion.kookie.space:5860"
            "inet:hub.irde.st:5860"
          ];
        };
        lan.enable = false;
      };
      description = ''
        Configuration for ratmand.

        See available options at https://codeberg.org/irdest/irdest/src/branch/main/ratman/src/config/ratmand-0.5.kdl.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Make ratman-tools available
    environment.systemPackages = [ cfg.package ];

    systemd.services.ratmand = {
      description = "Decentralized peer-to-peer packet router";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = ''
          ${lib.getExe' cfg.package "ratmand"} \
            --config "${configFile}" \
            --dir "$STATE_DIRECTORY"
        '';
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        StateDirectory = "ratmand";
        StateDirectoryMode = "0700";
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
    };
  };
}
