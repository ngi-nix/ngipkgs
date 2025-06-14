{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.holo;
in
{
  options.programs.holo = {
    enable = lib.mkEnableOption "holo";
    package = lib.mkPackageOption pkgs "holo-cli" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
