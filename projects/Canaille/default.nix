{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs) canaille;
  };
  nixos = {
    modules.services.canaille = "${sources.inputs.nixpkgs}/nixos/modules/services/security/canaille.nix";
    tests.canaille = "${sources.inputs.nixpkgs}/nixos/tests/canaille.nix";
    examples = null;
  };
}
