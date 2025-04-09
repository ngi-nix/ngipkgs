{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs)
      forgejo
      forgejo-cli
      forgejo-runner
      ;
  };
  nixos = {
    modules.services.forgejo = "${sources.inputs.nixpkgs}/nixos/modules/services/misc/forgejo.nix";
    tests = pkgs.nixosTests.forgejo;
    examples = null;
  };
}
