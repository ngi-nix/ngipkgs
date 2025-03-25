{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.foobar;
in
{
  options.programs.foobar = {
    enable = lib.mkEnableOption "foobar";
  };
}
