{
  lib,
  config,
  ...
}:
let
  cfg = config.programs._programName_;
in
{
  config = lib.mkIf cfg.enable {
    demo-shell = {
      programs = {
        _programName_ = cfg.package;
      };
      env = {
        PROGRAM_PORT = toString cfg.port;
      };
    };
  };
}
