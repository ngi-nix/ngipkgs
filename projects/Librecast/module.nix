{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.librecast;
in
{
  options.programs.librecast = {
    enable = lib.mkEnableOption "librecast";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lcrq
      lcsync
      librecast
    ];
  };
}
