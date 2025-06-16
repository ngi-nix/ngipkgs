{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kaidan;
in
{
  options.programs.kaidan = {
    enable = lib.mkEnableOption "enable Kaidan";
    package = lib.mkPackageOption pkgs "kaidan" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
