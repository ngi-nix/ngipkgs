{
  lib,
  pkgs,
  sources,
}@args:
{
  metadata = {
    summary = ''
      Inventaire is a libre/free webapp to make inventories and lists of books, and facilitates book sharing. By
      aggregating individuals' and collectives' book inventories from around the world, Inventaire is kind of a
      huge, distributed community library.
    '';
    subgrants = [
      "Inventaire"
      "Inventaire2"
      "Inventaire-Self-hosted"
    ];
  };

  nixos = {
    modules.services.inventaire = {
      module = ./module.nix;
      examples = {
        basic = {
          description = ''
            A (very insecure!) example of setting up Inventaire and its dependencies on the local machine.
          '';
          module = ./examples/basic.nix;
          tests.basic = import ./tests/basic.nix args;
        };
      };
    };
  };
}
