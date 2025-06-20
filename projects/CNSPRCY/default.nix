{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "E2EE connections between trusted devices for establishing private group chats.";
    subgrants = [
      "CNSPRCY"
    ];
    links = {
      source = {
        text = "CNSPRCY source code";
        url = "https://git.sr.ht/~xaos/cnsprcy";
      };
    };
  };

  nixos.modules.programs.cnsprcy = {
    name = "cnsprcy";
    module = ./programs/cnsprcy/module.nix;
    examples.basic = {
      module = ./programs/cnsprcy/examples/basic.nix;
      description = "Checks for cnspr executable";
      tests.basic = import ./programs/cnsprcy/tests/basic.nix args;
    };
  };

  nixos.modules.services.cnsprcy = {
    name = "cnsprcy";
    module = ./services/cnsprcy/module.nix;
    examples.basic = {
      module = ./services/cnsprcy/examples/basic.nix;
      description = "Checks that cnsprcy systemd service is running";
      tests.basic = import ./services/cnsprcy/tests/basic.nix args;
    };
  };
}
