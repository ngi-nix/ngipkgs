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
    zwm-client = {
      module = ./programs/0wm-client/module.nix;
      examples."Enable 0WM client" = {
        module = ./programs/0wm-client/examples/basic.nix;
        description = '''';
        tests.basic.module = import ./programs/0wm-client/tests/basic.nix args;
      };
    };
  };

  nixos.modules.services = {
    zwm-server = {
      module = ./services/0wm-server/module.nix;
      examples."Enable 0WM server" = {
        module = ./services/0wm-server/examples/basic.nix;
        description = '''';
        tests.basic.module = import ./services/0wm-server/tests/basic.nix args;
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
    tests.demo.module = import ./programs/_programName_/tests/basic.nix args;
  };
}
