{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.jaq;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      jaq = cfg.package;
    };
  };
}
