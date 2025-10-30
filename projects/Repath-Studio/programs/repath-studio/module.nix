{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.repath-studio;
in
{
  options.programs.repath-studio = {
    enable = lib.mkEnableOption "repath-studio";
    package = lib.mkPackageOption pkgs "repath-studio" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
  };
}
