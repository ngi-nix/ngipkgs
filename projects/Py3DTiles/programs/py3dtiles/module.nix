{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.py3dtiles;
in
{
  options.programs.py3dtiles = {
    enable = lib.mkEnableOption "py3dtiles";
    package = lib.mkPackageOption pkgs "py3dtiles" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
