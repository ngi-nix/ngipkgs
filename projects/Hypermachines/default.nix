{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Realtime and Collaborative P2P Search.";
    subgrants = [
      "Hypermachines"
    ];
  };

  nixos.programs = {
    Hypermachines = {
      name = "Hypermachines";
      module = ./programs/Hypermachines/module.nix;
      examples.basic = {
        module = ./programs/Hypermachines/examples/basic.nix;
        description = "";
        tests.basic = import ./programs/Hypermachines/tests/basic.nix args;
      };
    };
  };
}
