{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.programs.zwm-client;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        zwm-client = cfg.package;
        zwm-opmode = pkgs._0wm-opmode;
        zwm-ap-mock = pkgs._0wm-ap-mock;
      };
      # env = {
      #   PROGRAM_PORT = toString cfg.port;
      # };
    };
  };
}
