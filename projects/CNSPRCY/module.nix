{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.cnsprcy;
in
{
  options.programs.cnsprcy = {
    enable = lib.mkEnableOption "cnsprcy";
    package = lib.mkPackageOption pkgs "cnsprcy" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
