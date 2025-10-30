{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.repath-studio;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        repath-studio = cfg.package;
      };
    };
  };
}
