{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.py3dtiles;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        py3dtiles = cfg.package;
      };
    };
  };
}
