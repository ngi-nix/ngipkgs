{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "E2EE connections between trusted devices for establishing private group chats.";
    subgrants = [
      "CNSPRCY"
    ];
    links = {
      exampleLink = {
        text = "Title";
        url = "<URL>";
      };
    };
  };

  # https://git.sr.ht/~xaos/cnsprcy/tree/master/item/src/config.rs
  nixos.modules.programs.cnsprcy = {
    name = "cnsprcy";
    module = ./programs/cnsprcy/module.nix;
    examples.basic = {
      module = ./programs/cnsprcy/examples/basic.nix;
      description = "";
      tests.basic = import ./programs/cnsprcy/tests/basic.nix args;
    };
  };

  nixos.modules.services.cnsprcy = {
    name = "cnsprcy";
    module = ./services/cnsprcy/module.nix;
    examples.basic = {
      module = ./services/cnsprcy/examples/basic.nix;
      description = "";
      tests.basic = import ./services/cnsprcy/tests/basic.nix args;
    };
  };
}
