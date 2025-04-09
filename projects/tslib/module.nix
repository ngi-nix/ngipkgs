{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tslib;
in
{
  options.programs.tslib = {
    enable = lib.mkEnableOption "tslib";
    package = lib.mkPackageOption pkgs "tslib" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
