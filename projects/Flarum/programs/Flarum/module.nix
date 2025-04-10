{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.flarum;
in
{
  options.programs.flarum = {
    enable = lib.mkEnableOption "flarum";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      flarum
    ];
  };
}
