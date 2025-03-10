{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.re-isearch;
in
{
  options.programs.re-isearch = {
    enable = lib.mkEnableOption "re-Isearch";
    package = lib.mkPackageOption pkgs "re-isearch" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
