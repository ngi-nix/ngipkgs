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
    withMediaRepo = lib.mkEnableOption ''
      the download & automatic adding of the libervia-media repository.

      Due to an issue with a license for one of the fonts, it is disabled by default.
      If you enable this, you'll also need to opt into the use of unfree derivations
    '';
  };

  config = let
    backend = pkgs.libervia-backend.override {withMedia = cfg.withMediaRepo;};
    desktop-kivy = pkgs.libervia-desktop-kivy.override {withMedia = cfg.withMediaRepo;};
  in
    lib.mkIf cfg.enable {
      environment.systemPackages = [backend desktop-kivy pkgs.libervia-web];

      services.dbus.packages = [backend];
    };
}
