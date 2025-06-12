{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.xrsh;
in
{
  options.programs.xrsh = {
    enable = lib.mkEnableOption "enable xrsh";
    package = lib.mkPackageOption pkgs "xrsh" { };
    port = lib.mkOption {
      description = ''
        Port to serve xrsh on
      '';
      type = lib.types.nullOr lib.types.port;
      default = 8080;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
    environment.variables = {
      XRSH_PORT = toString cfg.port;
    };
    demo-shell.xrsh = {
      programs = {
        xrsh = cfg.package;
      };
      env.XRSH_PORT = "8090";
    };
  };
}
