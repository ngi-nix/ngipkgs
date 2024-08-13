{
  pkgs,
  lib,
  sources,
} @ args: {
  nixos = {
    examples.base = {
      description = ''
        Basic example for Weblate, with manual secrets deployment and automatic Nginx/ACME setup.
      '';
      path = ./examples/base.nix;
    };
  };
}
