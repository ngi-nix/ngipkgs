{
  pkgs,
  lib,
  sources,
}@args:
{
  metadata = {
    summary = "Shared agenda for local communities that supports Activity Pub";
    subgrants = [
      "Gancio"
    ];
  };
  nixos.services = {
    gancio = {
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/web-apps/gancio.nix";
      examples.gancio = {
        module = ./example.nix;
        description = "";
        tests.gancio = "${sources.inputs.nixpkgs}/nixos/tests/gancio.nix";
      };
    };
  };
}
