{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {
    inherit (pkgs) rosenpass rosenpass-tools;
  };
  nixos = {
    modules.services.rosenpass = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/rosenpass.nix";
    tests.rosenpass = import ./tests args;
    examples = null;
  };
}
