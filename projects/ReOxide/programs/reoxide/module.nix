{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.reoxide;
in
{
  options.programs.xrsh = {
    enable = lib.mkEnableOption "enable reoxide";
    package = lib.mkPackageOption pkgs "reoxide" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
