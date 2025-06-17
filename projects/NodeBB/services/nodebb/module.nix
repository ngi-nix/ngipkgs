{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.nodebb;
in
{
  options.services.nodebb = {
    enable = lib.mkEnableOption "NodeBB";
    package = lib.mkPackageOption pkgs "nodebb" { };
  };

  config = lib.mkIf cfg.enable {
  };
}
