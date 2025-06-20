{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Shared agenda for local communities that supports Activity Pub";
    subgrants = [
      "Gancio"
    ];
  };
  nixos.modules.services = {
    gancio = {
      module = lib.moduleLocFromOptionString "services.gancio";
      examples.gancio = {
        module = ./example.nix;
        description = "";
        tests.gancio = "${sources.inputs.nixpkgs}/nixos/tests/gancio.nix";
      };
    };
  };
}
