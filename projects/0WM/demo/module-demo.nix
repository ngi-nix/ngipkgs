{
  lib,
  config,
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
      };
      # env = {
      #   PROGRAM_PORT = toString cfg.port;
      # };
    };
  };
}
