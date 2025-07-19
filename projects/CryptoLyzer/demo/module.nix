{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.cryptolyzer;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell.programs = {
      cryptolyzer = cfg.package;
    };
  };
}
