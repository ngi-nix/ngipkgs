{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) weblate;
  };
  nixos = {
    modules.services.weblate = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/weblate.nix";
    examples.base = {
      description = ''
        Basic example for Weblate, with manual secrets deployment and automatic Nginx/ACME setup.
      '';
      path = ./examples/base.nix;
    };
  };
}
