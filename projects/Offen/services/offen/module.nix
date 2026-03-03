{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.offen;
in
{
  options.services.offen = {
    enable = lib.mkEnableOption "offen";
    package = lib.mkPackageOption pkgs "offen" { };
  };
}
