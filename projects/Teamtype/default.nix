{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Peer-to-peer, editor-agnostic collaborative editing of local text files.";
    subgrants = {
      Core = [
        "Teamtype"
      ];
    };
    links = {
      repo = {
        text = "Homepage";
        url = "https://teamtype.github.io";
      };
      docs = {
        text = "Documentation";
        url = "https://teamtype.github.io";
      };
      src = {
        text = "Source repository";
        url = "https://github.com/teamtype/teamtype";
      };
    };
  };

  nixos.modules.programs = {
    teamtype = {
      module = ./programs/teamtype/module.nix;
      examples."Enable Teamtype" = {
        module = ./programs/teamtype/examples/basic.nix;
        tests.basic.module = ./programs/teamtype/tests/basic.nix;
        tests.basic.problem.broken.reason = ''
          Needs a self-hosted relay server to work non-interactively (without internet).
          Requires: https://github.com/teamtype/teamtype/issues/344
        '';
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/teamtype/examples/basic.nix;
    module-demo = ./module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          First, create a directory with a subdirectory named `.teamtype` and
          share it:

          ```
          $ mkdir .teamtype
          $ teamtype share --show-secret-address
          ```

          Wait a few seconds and a secret address will be printed that can be
          used to connect to this server.
        '';
      }
      {
        instruction = ''
          Next, create another directory and add the secret address from the
          previous step to its config file:

          ```
          $ mkdir .teamtype
          $ echo peer="<secret-address>" >.teamtype/config
          $ teamtype join
          ```

          Then, join the shared directory:

          ```
          $ teamtype join
          ```

          The two directories are now connected.
        '';
      }
      {
        instruction = ''
          You can now edit files in one directory and the changes will be synchronized
          in the other. If you use Neovim, the instance in this shell has also been
          configured with the Teamtype plugin, so you can try using `:TeamtypeInfo` and
          `:TeamtypeJumpToCursor`.

          For more information on using this project, please refer to the
          [project documentation](https://teamtype.github.io).
        '';
      }
    ];
    tests.demo.module = ./programs/teamtype/tests/basic.nix;
    tests.demo.problem.broken.reason = ''
      Needs a self-hosted relay server to work non-interactively (without internet).
      Requires: https://github.com/teamtype/teamtype/issues/344
    '';
  };
}
