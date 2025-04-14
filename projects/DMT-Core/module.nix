{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.dmt-core;
in
{
  options.programs.dmt-core = {
    enable = lib.mkEnableOption "dmt-core";
    package = lib.mkPackageOption pkgs [ "python3Packages" "dmt-core" ] { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
