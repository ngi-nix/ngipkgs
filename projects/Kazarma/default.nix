{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Matrix bridge for the ActivityPub network";
    subgrants = {
      Entrust = [
        "Kazarma-Release"
      ];
      Review = [
        "Kazarma"
      ];
    };
    links = {
      website = {
        text = "Website";
        url = "https://kazar.ma/";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.kazar.ma/";
      };
      src = {
        text = "Source repository";
        url = "https://gitlab.com/technostructures/kazarma/kazarma";
      };
    };
  };

  nixos.modules.services = {
    kazarma = {
      name = "service name";
      module = ./services/kazarma/module.nix;
      examples."Enable kazarma" = {
        module = ./services/kazarma/examples/basic.nix;
        description = null;
        tests.basic.module = ./services/kazarma/tests/basic.nix;
      };
    };
  };
}
