{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.briar;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        biar = cfg.package;
      };
    };
  };
}
