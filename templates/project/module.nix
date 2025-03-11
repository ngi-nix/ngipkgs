{ lib, ... }:
{
  options.programs.foobar = {
    enable = lib.mkEnableOption "foobar";
  };
}
