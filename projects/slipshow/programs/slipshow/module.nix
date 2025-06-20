{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.slipshow;
in
{
  options.programs.slipshow = {
    enable = lib.mkEnableOption "slipshow";
    package = lib.mkPackageOption pkgs "slipshow" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
