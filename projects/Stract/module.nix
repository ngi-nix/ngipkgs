{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.stract;
in
{
  options.programs.stract = {
    enable = lib.mkEnableOption "stract";
    package = lib.mkPackageOption pkgs "stract" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
