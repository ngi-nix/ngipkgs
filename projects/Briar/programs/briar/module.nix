{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.briar;
in
{
  options.programs.briar = {
    enable = lib.mkEnableOption "briar";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      briar-desktop
    ];
  };
}
