{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.oku;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      oku = cfg.package;
    };
  };
}
