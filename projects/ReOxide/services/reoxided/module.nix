{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    types
    ;

  cfg = config.services.reoxided;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "reoxide.toml" cfg.settings;

in
{
  options.services.reoxided = {
    enable = mkEnableOption "enable reoxided";
    package = mkPackageOption pkgs "reoxide" { };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = {
          ghidra-install = mkOption {
            type =
              with types;
              listOf (submodule {
                freeformType = settingsFormat.type;
                options = {
                  enabled = mkOption {
                    type = types.bool;
                    default = true;
                    description = "Enable this Ghidra installation";
                  };
                  root-dir = mkOption {
                    type = types.str;
                    default = "${cfg.package}/opt/ghidra";
                    description = "Ghidra root install directory";
                  };
                };
              });
            default = [ ];
            description = "List of Ghidra installations to configure";
          };
        };
      };
      default = { };
      example = lib.literalExpression ''
        {
          ghidra-install = [
            {
              enabled = true;
              default = "${pkgs.reoxide}/opt/ghidra";
            }
          ];
        };
      '';
      description = "Reoxide settings";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];

    systemd.services.reoxided = {
      description = "ReOxide daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/reoxided -c ${configFile}";
        Restart = "always";
        RestartSec = 5;
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = 100;
      };
    };
  };
}
