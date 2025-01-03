{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = { inherit (pkgs) cryptpad; };
  nixos = {
    modules.services.cryptpad = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/cryptpad.nix";
    # https://hydra.nixos.org/job/nixos/trunk-combined/nixos.tests.cryptpad.x86_64-linux
    # tests.cryptpad = import "${sources.inputs.nixpkgs}/nixos/tests/cryptpad.nix" args;
    examples = null;
  };
}
