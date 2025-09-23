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
  options.programs.reoxide = {
    enable = lib.mkEnableOption "enable reoxide";
    package = lib.mkPackageOption pkgs "reoxide" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
      reoxide-plugin-simple
    ];
  };
}
