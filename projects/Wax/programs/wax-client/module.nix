{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wax-client;
in
{
  options.programs.wax-client = {
    enable = lib.mkEnableOption "enable wax-client";
    package = lib.mkPackageOption pkgs "wax-client" { };
    serverUrl = lib.mkOption {
      description = ''
        Wax server access url
      '';
      type = lib.types.nullOr lib.types.str;
      default = "http://localhost:3000";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cfg.package
    ];
    environment.variables = {
      SERVER_URL = cfg.serverUrl;
    };
  };
}
