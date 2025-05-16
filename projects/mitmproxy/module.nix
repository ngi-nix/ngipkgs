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
    app-shell.mitmproxy.programs = {
      mitmproxy = cfg.package;
    };
  };
}
