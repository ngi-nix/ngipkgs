{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Vector graphics editor, that combines procedural tooling with traditional design workflows";
    subgrants.Commons = [ "RepathStudio" ];
    links = {
      repo = {
        text = "Source repository";
        url = "https://github.com/repath-project/repath-studio";
      };
      homepage = {
        text = "Homepage";
        url = "https://repath.studio";
      };
      docs = null;
      blog = {
        text = "Blog";
        url = "https://repath.studio/blog/";
      };
    };
  };

  nixos.modules.programs = {
    repath-studio = {
      name = "repath-studio";
      module = ./programs/repath-studio/module.nix;
      examples."Enable repath-studio" = {
        module = ./programs/repath-studio/examples/basic.nix;
        tests.basic.module = ./programs/repath-studio/tests/basic.nix;
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://repath.studio/get-started/build-from-source/";
        };
        test = {
          text = "Test instructions";
          url = "https://repath.studio/get-started/interactive-shell/#examples";
        };
      };
    };
  };

  nixos.demo.shell = {
    module = ./demo/module.nix;
    module-demo = ./demo/module-demo.nix;
    usage-instructions = [
      {
        instruction = ''
          Run `repath-studio` in the terminal
        '';
      }
      {
        instruction = ''
          Verify the graphical window opens for Repath Studio.
        '';
      }
    ];
    tests.demo.module = ./programs/repath-studio/tests/basic.nix;
  };
}
