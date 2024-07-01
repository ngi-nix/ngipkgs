{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) weblate;};
  nixos = {
    modules.services.weblate = ./service.nix;
    tests.integration-test = import ./tests/integration-test.nix args;
  };
}
