{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.icosa-gallery;
in
{
  options.services.icosa-gallery = {
    enable = lib.mkEnableOption "Icosa Gallery";
    package = lib.mkPackageOption pkgs "icosa-gallery" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
