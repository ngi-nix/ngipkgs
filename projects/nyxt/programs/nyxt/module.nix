{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.nyxt;
in
{
  options.programs.nyxt = {
    enable = lib.mkEnableOption "nyxt";
    package = lib.mkPackageOption pkgs "nyxt" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
