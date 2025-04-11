{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.dokieli;
in
{
  options.programs.dokieli = {
    enable = lib.mkEnableOption "dokieli";
    package = lib.mkPackageOption pkgs "dokieli" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
