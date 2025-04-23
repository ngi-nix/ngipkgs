{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.naja;
in
{
  options.programs.naja = {
    enable = lib.mkEnableOption "naja";
    package = lib.mkPackageOption pkgs "naja" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
