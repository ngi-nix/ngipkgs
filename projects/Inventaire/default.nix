{
  lib,
  pkgs,
  sources,
  ...
}@args:
{
  metadata = {
    summary = ''
      Inventaire is a libre/free webapp to make inventories and lists of books, and facilitates book sharing. By
      aggregating individuals' and collectives' book inventories from around the world, Inventaire is kind of a
      huge, distributed community library.
    '';
    subgrants = {
      Entrust = [
        "Inventaire-Self-hosted"
      ];
      Review = [
        "Inventaire"
        "Inventaire2"
      ];
    };
  };

  nixos = {
    modules.services.inventaire = {
      links = {
        settings-types = {
          text = "TypeScript file listing the intended types of every setting";
          url = "https://codeberg.org/inventaire/inventaire/src/branch/main/server/types/config.ts";
        };
        settings-defaults = {
          text = "Default settings";
          url = "https://codeberg.org/inventaire/inventaire/src/branch/main/config/default.cjs";
        };
      };
      module = ./module.nix;
      examples."Enable Inventaire" = {
        description = ''
          A (very insecure!) example of setting up Inventaire and its dependencies on the local machine.
        '';
        module = ./examples/basic.nix;
        tests.basic.module = ./tests/basic.nix;
      };
    };
    demo.vm = {
      module = ./examples/basic.nix;
      module-demo = ./module-demo.nix;
      tests.basic.module = ./tests/basic.nix;
    };
  };
}
