{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.mitmproxy;
in
{
  options.programs.mitmproxy = {
    enable = lib.mkEnableOption "mitmproxy";
    package = lib.mkPackageOption pkgs "mitmproxy" { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
  };
}
