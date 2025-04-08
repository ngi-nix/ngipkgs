{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services._serviceName_;
in
{
  options.services._serviceName_ = {
    enable = lib.mkEnableOption "service name";
  };
}
