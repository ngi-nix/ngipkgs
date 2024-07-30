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
    pkg = pkgs.libervia-backend.override {withMedia = cfg.withMediaRepo;};
  in
    lib.mkIf cfg.enable {
      environment.systemPackages = [pkg];

      services.dbus.packages = [pkg];
    };
}
