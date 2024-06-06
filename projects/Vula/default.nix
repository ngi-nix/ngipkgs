{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = ["vula"];
  nixos = {
    modules.services.vula = ./service.nix;
    tests.vula = import ./test.nix args;
  };
}
