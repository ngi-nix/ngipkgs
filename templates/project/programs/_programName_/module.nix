{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs._programName_;
in
{
  options.programs._programName_ = {
    enable = lib.mkEnableOption "program name";
  };
}
