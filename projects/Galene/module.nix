{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.galene;
in
{
  options.programs.galene = {
    enable = lib.mkEnableOption "galene";
  };
}
