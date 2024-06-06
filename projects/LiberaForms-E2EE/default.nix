{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = ["liberaforms"];
  nixos = {
    modules.services.liberaforms = ./service.nix;
    tests.liberaforms = import ./test.nix args;
  };
}
