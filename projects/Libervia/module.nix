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
    backend.enable = lib.mkEnableOption "Libervia backend and CLI/TUI clients";
    kivy.enable = lib.mkEnableOption "Libervia Kivy desktop client";
  };

  config = lib.mkMerge [
    # Backend
    (lib.mkIf cfg.backend.enable {
      environment.systemPackages = with pkgs; [
        libervia-backend
      ];

      services.dbus.packages = with pkgs; [ libervia-backend ];
    })

    # Kivy client
    (lib.mkIf cfg.kivy.enable {
      # Also needs the backend
      programs.libervia.backend.enable = true;

      environment.systemPackages = with pkgs; [
        libervia-desktop-kivy
      ];
    })
  ];
}
