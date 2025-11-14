{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.bonfire;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        bonfire = cfg.package;
      };
      env = {
        PROGRAM_PORT = toString cfg.port;
      };
    };
  };
}
