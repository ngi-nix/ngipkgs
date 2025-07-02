{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.eris-go;
in
{
  options.programs.eris-go = {
    enable = lib.mkEnableOption "eris-go";
    package = lib.mkPackageOption pkgs "eris-go" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
