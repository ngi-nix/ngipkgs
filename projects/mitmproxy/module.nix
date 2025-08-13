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
    swagger = {
      enable = lib.mkEnableOption "mitmproxy2swagger";
      package = lib.mkPackageOption pkgs "mitmproxy2swagger" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ]
    + lib.optional cfg.swagger.enable cfg.swagger.package;
  };
}
