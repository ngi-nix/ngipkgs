{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.verso;
in
{
  options.programs.verso = {
    enable = lib.mkEnableOption "verso";
    package = lib.mkPackageOption pkgs "verso" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
