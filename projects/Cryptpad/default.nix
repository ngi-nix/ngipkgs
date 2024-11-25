{
  pkgs,
  lib,
  sources,
} @ args: {
  packages = {inherit (pkgs) cryptpad;};
  nixos = {
    modules.services.cryptpad = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/cryptpad.nix";
    tests.cryptpad = import "${sources.inputs.nixpkgs}/nixos/tests/cryptpad.nix" args;
    examples = null;
  };
}
