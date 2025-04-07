{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.galene;
in
{
  options.services.galene = {
    enable = lib.mkEnableOption "galene";
  };
}
