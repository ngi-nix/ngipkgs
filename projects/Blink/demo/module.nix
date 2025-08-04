{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.blink;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      blink = cfg.package;
    };
  };
}
