{
  lib,
  pkgs,
  ...
}@args:

{
  metadata = {
    summary = "Open source software forge with a focus on federation";
    subgrants.Entrust = [
      "Federated-Forgejo"
      "Forgejo"
    ];
    links = {
      docs = {
        text = "Documentation";
        url = "https://forgejo.org/docs";
      };
    };
  };

  nixos.modules.programs = {
    forgejo = {
      module = ./program/module.nix;
      examples."Enable Forgejo program" = {
        module = ./program/example.nix;
        description = "";
        tests.program.module = null;
      };
    };
  };

  nixos.modules.services = {
    forgejo = {
      module = lib.moduleLocFromOptionString "services.forgejo";
      examples."Enable Forgejo service" = {
        module = null;
      };
    };
  };

  nixos.tests =
    lib.foldl'
      (
        acc: dbType:
        acc
        // {
          "${dbType}".module = pkgs.nixosTests.forgejo.${dbType};
          "${dbType}-lts".module = pkgs.nixosTests.forgejo-lts.${dbType};
        }
      )
      { }
      [
        "mysql"
        "sqlite3"
        "postgres"
      ];
}
