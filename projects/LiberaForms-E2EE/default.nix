{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) liberaforms;
  };
  nixos = {
    modules.services.liberaforms = ./service.nix;
    tests.liberaforms = import ./test.nix args;
  };
}
