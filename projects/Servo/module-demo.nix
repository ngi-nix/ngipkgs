{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.servo;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        servo = cfg.package;
      };
    };
  };
}
