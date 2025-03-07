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
    enable = lib.mkEnableOption "Libervia backend and CLI/TUI clients";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libervia-backend
    ];

    services.dbus.packages = with pkgs; [ libervia-backend ];
  };
}
