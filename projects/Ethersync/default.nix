{
  lib,
  pkgs,
  sources,
  ...
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

  nixos = {
    modules.programs = {
      ethersync = {
        name = "ethersync";
        module = ./programs/ethersync/module.nix;
        examples = {
          "Using Ethersync" = {
            module = ./programs/ethersync/examples/basic.nix;
            tests.basic.module = import ./programs/ethersync/tests/basic.nix args;
          };
        };
      };
    };
    demo.shell = {
      module = ./programs/ethersync/examples/basic.nix;
      description = ''
        Ethersync enables real-time collaborative editing of local text files.

        To test, first create a directory with a subdirectory named `.ethersync` and
        run `ethersync daemon`, wait a few seconds it will print URLs that can be used
        to connect to this server.

        Then, create another directory with a subdirectory named `.ethersync` and run
        `ethersync daemon --peer <URL>`, the two directories are now connected.

        Now you can edit files in one directory and the changes will be synchronized
        in the other.  If you use Neovim, the instance in this shell has also been
        configured with the Ethersync plugin, so you can try using :EthersyncInfo and
        :EthersyncJumpToCursor.
      '';
      tests.basic.module = import ./programs/ethersync/tests/basic.nix args;
    };
  };
}
