{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.mitmproxy;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      mitmproxy = cfg.package;
    };
  };
}
