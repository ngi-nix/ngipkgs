{
  lib,
  config,
  ...
}:
let
  cfg = config.services.goupile;
in
{
  config = lib.mkIf cfg.enable { };
}
