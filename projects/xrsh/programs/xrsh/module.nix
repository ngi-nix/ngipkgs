{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.xrsh;
in
{
  options.programs.xrsh = {
    enable = lib.mkEnableOption "xrsh";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xrsh
    ];
  };
}
