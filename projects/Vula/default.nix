{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) vula;};
  nixos = {
    modules.services.vula = ./service.nix;
    tests.vula = import ./test.nix args;
  };
}
