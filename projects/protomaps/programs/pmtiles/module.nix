{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.pmtiles;
in
{
  options.programs.pmtiles = {
    enable = lib.mkEnableOption "pmtiles";
    package = lib.mkPackageOption pkgs "pmtiles" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
