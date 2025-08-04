{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.owi;
in
{
  options.programs.owi = {
    enable = lib.mkEnableOption "owi";
    package = lib.mkPackageOption pkgs "owi" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
