{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.basic;
in
{
  options.programs.scion = {
    enable = lib.mkEnableOption "scion";
  };
}
