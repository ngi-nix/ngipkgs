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
    enable = lib.mkEnableOption "_serviceName_";
    # replace `_package_` with the main service package, if it exists in https://search.nixos.org/packages
    # else, remove the line below
    package = lib.mkPackageOption pkgs "_package_" { };
  };
}
