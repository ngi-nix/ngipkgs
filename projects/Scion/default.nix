{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs)
      scion
      scion-apps
      scion-bootstrapper
      ioq3-scion
      pan-bindings
      ;
  };
  nixos = {
    modules.services.scion = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/scion/scion.nix";
    # TODO: unbreak
    # tests.scion = "${sources.inputs.nixpkgs}/nixos/tests/scion/freestanding-deployment/default.nix";
    tests = null;
    examples = null;
  };
}
