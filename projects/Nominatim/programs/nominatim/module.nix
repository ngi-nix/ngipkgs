{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nominatim;
in
{
  options.programs.nominatim = {
    enable = lib.mkEnableOption "nominatim";
    package = lib.mkPackageOption pkgs "nominatim" { };
  };

  config = lib.mkIf cfg.enable {
    demo-shell.nominatim.programs = {
      nominatim = cfg.package;
    };
  };
}
