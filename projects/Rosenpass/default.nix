{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = ["rosenpass" "rosenpass-tools"];
  nixos = {
    modules.services.rosenpass = null;
    tests.rosenpass = import ./tests args;
  };
}
