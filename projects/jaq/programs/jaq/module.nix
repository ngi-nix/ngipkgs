{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.jaq;
in
{
  options.programs.jaq = {
    enable = lib.mkEnableOption "jaq";
    package = lib.mkPackageOption pkgs "jaq" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
