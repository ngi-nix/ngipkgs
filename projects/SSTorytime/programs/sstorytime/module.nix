{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.sstorytime;

  inherit (lib)
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.programs.sstorytime = {
    enable = mkEnableOption "SSTorytime";
    package = mkPackageOption pkgs "sstorytime" { };

    sstConfigDir = mkOption {
      type = types.path;
      description = "Path to the directory containing the SSTconfig files.";
      default = "${cfg.package}/share/config/SSTconfig";
      defaultText = lib.literalExpression "''${pkgs.sstorytime}/share/config/SSTconfig";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.variables.SST_CONFIG_PATH = cfg.sstConfigDir;
    environment.systemPackages = [
      cfg.package
    ];
  };
}
