{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.blink;
in
{
  options.programs.blink = {
    enable = lib.options.mkEnableOption "Blink SIP client";

    package = lib.options.mkPackageOption pkgs "blink-qt" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
