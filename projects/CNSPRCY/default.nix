{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "E2EE connections between trusted devices for establishing private group chats.";
    subgrants.Review = [
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
    module = ./programs/cnsprcy/module.nix;
    examples."Enable CNSPRCY program" = {
      module = ./programs/cnsprcy/examples/basic.nix;
      description = "Checks for cnspr executable";
      tests.basic.module = ./programs/cnsprcy/tests/basic.nix;
    };
  };

  nixos.modules.services.cnsprcy-server = {
    module = ./services/cnsprcy/module.nix;
    examples."Enable CNSPRCY service" = {
      module = ./services/cnsprcy/examples/basic.nix;
      description = "Checks that cnsprcy systemd service is running";
      tests.basic.module = ./services/cnsprcy/tests/basic.nix;
    };
  };
}
