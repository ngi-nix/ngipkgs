{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.gnucap;
in
{
  options.programs.gnucap = {
    enable = lib.mkEnableOption "gnucap";
    package = lib.mkPackageOption pkgs "gnucap" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
