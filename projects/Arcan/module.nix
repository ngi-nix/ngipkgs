{ lib, ... }:
{
  options.programs.arcan = {
    enable = lib.mkEnableOption "arcan";
  };
}
