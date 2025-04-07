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
  options.programs.basic = {
    enable = lib.mkEnableOption "scoin";
  };
}
