{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.alive2;
in
{
  options.programs.alive2 = {
    enable = lib.mkEnableOption "alive2";
    package = lib.mkPackageOption pkgs "alive2" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
