{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Ethersync aims to enable real-time collaborative editing of local text files. Similar to Etherpads, it facilitates multiple users to work on content simultaneously, enabling applications such as shared notes or pair programming.";
    subgrants = [
      "Ethersync"
    ];
    links = {
      docs = {
        text = "Documentation";
        url = "https://ethersync.github.io/ethersync/";
      };
      src = {
        text = "Source repository";
        url = "https://github.com/ethersync/ethersync";
      };
    };
  };

  nixos.modules.programs = {
    ethersync = {
      name = "ethersync";
      module = ./programs/ethersync/module.nix;
      examples = {
        demo-shell = {
          module = ./programs/ethersync/examples/basic.nix;
          description = "";
          tests.basic = import ./programs/ethersync/tests/basic.nix args;
        };
      };
    };
  };
}
