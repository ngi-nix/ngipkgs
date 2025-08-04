{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.owi;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      owi = cfg.package;
    };
  };
}
