{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.oku;
in
{
  options.programs.oku = {
    enable = lib.mkEnableOption "oku";
    package = lib.mkPackageOption pkgs "oku" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
    demo-shell.oku.programs = {
      oku = cfg.package;
    };
  };
}
