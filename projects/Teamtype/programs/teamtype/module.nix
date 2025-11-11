{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.teamtype;
in
{
  options.programs.teamtype = {
    enable = lib.mkEnableOption "Teamtype";
    package = lib.mkPackageOption pkgs "teamtype" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
