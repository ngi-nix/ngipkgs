{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.meta-presses;
in
{
  options.programs.meta-presses = {
    enable = lib.mkEnableOption "meta-presses";
    # firefox addon
    package = lib.mkPackageOption pkgs "meta-press" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
