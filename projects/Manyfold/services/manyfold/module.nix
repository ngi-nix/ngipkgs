{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.manyfold;
in
{
  options.services.manyfold = {
    enable = lib.mkEnableOption "Manyfold";
    package = lib.mkPackageOption pkgs "manyfold" { };
  };
}
