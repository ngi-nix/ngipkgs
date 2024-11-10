{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.libervia;
in {
  options.programs.libervia = {
    enable = lib.mkEnableOption "Libervia";
  };

  config = let
    pkg = pkgs.libervia-backend;
  in
    lib.mkIf cfg.enable {
      environment.systemPackages = [pkg];

      services.dbus.packages = [pkg];
    };
}
