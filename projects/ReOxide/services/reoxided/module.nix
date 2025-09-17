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
    types
    ;

  cfg = config.services.reoxided;
  toToml = pkgs.formats.toml { };
  configFile = toToml.generate "reoxide.toml" {
    ghidra-install = cfg.ghidraInstall;
  };

in
{
  options.services.reoxided = {
    enable = mkEnableOption "enable reoxided";
    package = mkPackageOption pkgs "reoxide" { };

    ghidraInstall = mkOption {
      type = types.listOf (types.submodule {
        freeformType = toToml.type;
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
      default = [
        {
          enabled = true;
          root-dir = "${cfg.package}/opt/ghidra";
        }
      ];
      description = "List of Ghidra installations to configure";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];

    environment.etc."reoxide.toml".source = configFile;

    systemd.services.reoxided = {
      description = "ReOxide daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/reoxided -c /etc/reoxide.toml";
        Restart = "always";
      };
    };
  };
}
