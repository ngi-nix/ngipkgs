{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.cnsprcy;
in
{
  options.programs.cnsprcy = {
    enable = lib.mkEnableOption "cnsprcy";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cnsprcy
    ];
  };
}
