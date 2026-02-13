{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.goupile;
in
{
  options.services.goupile = {
    enable = lib.mkEnableOption "Goupile server";
    package = lib.mkPackageOption pkgs "goupile" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.goupile = { };
  };
}
