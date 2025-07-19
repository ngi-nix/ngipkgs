{ pkgs, ... }@args:
{
  metadata = {
    summary = "Modular protocol for sharing, modifying and modeling graph data";
    subgrants = [
      "AtomicData"
      "AtomicTables"
    ];
  };

  nixos = {
    modules.services.atomic-server = {
      module = ./service.nix;
      examples."Enable Atomic Server" = {
        module = ./example.nix;
        tests.atomic-server.module = import ./test.nix args;
      };
    };
  };
}
