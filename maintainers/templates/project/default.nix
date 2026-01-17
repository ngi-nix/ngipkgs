{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  /**
    NOTE
    - Each program/service must have at least one example
    - Each example must be tested
    - If something is needed but not available, set its attribute to `null`
    - Remove template comments before committing changes

    See the [project reference document](https://github.com/ngi-nix/ngipkgs/blob/main/maintainers/docs/project.md) for more details on how to implement each component.
  */
  metadata = {
    summary = "Short summary that describes the project";
    subgrants = {
      Commons = [ ];
      Core = [ ];
      Entrust = [ ];
      Review = [ ];
    };
    # Top-level links for things that are in common across the whole project (mandatory)
    links = {
      repo = {
        text = "Title";
        url = "<URL>";
      };
      homepage = {
        text = "Title";
        url = "<URL>";
      };
      docs = {
        text = "Title";
        url = "<URL>";
      };
    };
  };

  nixos.modules.programs = {
    _programName_ = {
      name = "_programName_";
      # if a project has `packages`, add them inside the `module.nix` file
      module = ./programs/_programName_/module.nix;
      examples."Enable _programName_" = {
        module = ./programs/_programName_/examples/basic.nix;
        description = ''
          Usage instructions

          1.
          2.
          3.
        '';
        tests.basic.module = ./programs/_programName_/tests/basic.nix;
      };
      # Add relevant links to the program (optional)
      links = {
        build = {
          text = "Build from source";
          url = "<URL>";
        };
        test = {
          text = "Test instructions";
          url = "<URL>";
        };
      };
    };
  };

  nixos.modules.services = {
    _serviceName_ = {
      name = "service name";
      module = ./services/_serviceName_/module.nix;
      examples."Enable _serviceName_" = {
        module = ./services/_serviceName_/examples/basic.nix;
        description = ''
          Usage instructions

          1.
          2.
          3.
        '';
        tests.basic.module = ./services/_serviceName_/tests/basic.nix;
      };
      # Add relevant links to the program (optional)
      links = {
        build = {
          text = "Build from source";
          url = "<URL>";
        };
        test = {
          text = "Test instructions";
          url = "<URL>";
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
          Run `foobar` in the terminal
        '';
      }
      {
        instruction = ''
          Visit [http://127.0.0.1:8080](http://127.0.0.1:8080) in your browser
        '';
      }
    ];
    tests.demo.module = ./programs/_programName_/tests/basic.nix;
  };
}
