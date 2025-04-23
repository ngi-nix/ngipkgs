{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.servo;
in
{
  options.programs.servo = {
    enable = lib.mkEnableOption "servo";
    package = lib.mkPackageOption pkgs "servo" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
