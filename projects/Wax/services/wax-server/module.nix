{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;
  cfg = config.services.wax-server;
in
{
  options.services.wax-server.enable = mkEnableOption "wax-server";
  options.services.wax-server.package = mkPackageOption pkgs "wax-server" { };

  options.services.wax-server.POSTGRES_DB = mkOption {
    type = types.str;
    description = "Postgres db";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
    environment.variables = {
      POSTGRES_DB = cfg.POSTGRES_DB;
    };
  };
}
