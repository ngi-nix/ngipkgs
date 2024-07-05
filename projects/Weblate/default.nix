{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) weblate;};
  nixos = {
    modules.services.weblate = ./service.nix;
    tests.integration-test = import ./tests/integration-test.nix args;
    examples.base = {
      description = ''
        Basic example for Weblate, with manual secrets deployment and automatic Nginx/ACME setup.
      '';
      path = ./examples/base.nix;
    };
  };
}
