{
  pkgs,
  lib,
  sources,
  ...
}@args:
{
  metadata = {
    summary = "Shared agenda for local communities that supports Activity Pub";
    subgrants.Core = [
      "Gancio"
    ];
  };
  nixos.modules.services = {
    gancio = {
      module = lib.moduleLocFromOptionString "services.gancio";
      examples."Enable Gancio" = {
        module = ./example.nix;
        tests.gancio.module = pkgs.nixosTests.gancio;
      };
    };
  };
}
