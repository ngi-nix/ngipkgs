{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kikit;
in
{
  options.programs.kikit = {
    enable = lib.mkEnableOption "kikit";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      kikit
      kicadAddons.kikit
      kicadAddons.kikit-library
    ];
  };
}
