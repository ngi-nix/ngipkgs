{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.scion;
in
{
  options.programs.scion = {
    enable = lib.mkEnableOption "scion";
  };
}
