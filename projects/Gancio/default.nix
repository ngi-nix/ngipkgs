
  {
  pkgs,
  lib,
  sources,
  ...
}@args:
{

   metadata = {
    summary = "Gancio Shared agenda for local communities that supports Activity";
    subgrants = [
      "gancio"
      "Hex designs"
    ];
  };

  packages = { inherit (pkgs) gancio; };
  nixos = {
    modules.services.gancio = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/gancio.nix";
    tests.gancio = "${sources.inputs.nixpkgs}/nixos/tests/gancio.nix";
    examples = null;
  };
}
