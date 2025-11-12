{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Unified Graph Process For Mapping Knowledge";
    subgrants = {
      Commons = [
        "SmartSemanticDataLookup"
      ];
    };
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/markburgess/SSTorytime";
      };
      homepage = {
        text = "Homepage";
        url = "https://markburgess.org/spacetime.html";
      };
      docs = {
        text = "Documentation";
        url = "https://github.com/markburgess/SSTorytime/blob/main/docs/README.md";
      };
    };
  };

  nixos.modules.programs = {
    sstorytime = {
      module = ./programs/sstorytime/module.nix;
      examples."Enable SSTorytime programs" = {
        module = ./programs/sstorytime/examples/basic.nix;
        tests.basic.module = import ./services/sstorytime/tests/basic.nix args;
      };
    };
  };

  nixos.modules.services = {
    sstorytime = {
      name = "service name";
      module = ./services/sstorytime/module.nix;
      examples."Enable SSTorytime server" = {
        module = ./services/sstorytime/examples/basic.nix;
        tests.basic.module = import ./services/sstorytime/tests/basic.nix args;
      };
    };
  };
}
