{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs) rosenpass rosenpass-tools;
  };
  nixos = {
    modules.services.rosenpass = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/rosenpass.nix";
    tests.with-sops = import ./tests args;
    tests.without-sops = "${sources.inputs.nixpkgs}/nixos/tests/rosenpass.nix";
    examples = null;
  };
}
