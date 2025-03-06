{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.libervia;
in
{
  options.programs.libervia = {
    enable = lib.mkEnableOption "Libervia";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libervia-backend
      libervia-desktop-kivy
    ];

    services.dbus.packages = with pkgs; [ libervia-backend ];
  };
}
