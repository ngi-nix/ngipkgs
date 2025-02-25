{
  pkgs,
  lib,
  sources,
}:
{
  packages = {
    inherit (pkgs)
      namecoind
      ncdns
      ;
  };

  nixos = {
    modules.services.namecoind = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/namecoind.nix";
    modules.services.ncdns = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/ncdns.nix";
    tests.ncdns = "${sources.inputs.nixpkgs}/nixos/tests/ncdns.nix";
  };
}
