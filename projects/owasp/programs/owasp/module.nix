{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.owasp;
in
{
  options.programs.owasp = {
    enable = lib.mkEnableOption "owasp";
    blint.package = lib.mkPackageOption pkgs "blint" { };
    dep-scan.package = lib.mkPackageOption pkgs "dep-scan" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.blint.package
      cfg.dep-scan.package
    ];
  };
}
