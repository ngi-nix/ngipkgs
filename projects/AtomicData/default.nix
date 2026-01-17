{ pkgs, ... }@args:
{
  metadata = {
    summary = "Modular protocol for sharing, modifying and modeling graph data";
    subgrants = {
      Commons = [
        "AtomicServer-LocalFirst"
      ];
      Entrust = [
        "AtomicTables"
      ];
      Review = [
        "AtomicData"
      ];
    };
    links = {
      homepage = {
        text = "Homepage";
        url = "https://atomicdata.dev";
      };
      repo = {
        text = "Source repository";
        url = "https://github.com/atomicdata-dev/atomic-server";
      };
      docs = {
        text = "Documentation";
        url = "https://docs.atomicdata.dev";
      };
    };
  };

  nixos = {
    modules.services.atomic-server = {
      module = ./service.nix;
      examples."Enable Atomic Server" = {
        module = ./example.nix;
        tests.atomic-server.module = ./test.nix;
      };
    };
  };
}
