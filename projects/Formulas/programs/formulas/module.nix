{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.formulas;
in
{
  options.programs.formulas = {
    enable = lib.mkEnableOption "formulas";
    package = lib.mkPackageOption pkgs "formulas" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
