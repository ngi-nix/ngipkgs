{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Programmatic reuse of spreadsheet formulas — parse and compile Excel workbooks in Python code.";
    subgrants = {
      Commons = [ "Formulas" ];
    };
    links = {
      repo = {
        text = "Repository";
        url = "https://github.com/vinci1it2000/formulas";
      };
      homepage = {
        text = "Home Page";
        url = "https://github.com/vinci1it2000/formulas";
      };
      docs = {
        text = "Documentation";
        url = "https://formulas.readthedocs.io";
      };
    };
  };

  nixos.modules.programs = {
    formulas = {
      name = "formulas";
      module = ./programs/formulas/module.nix;
      examples.basic = {
        module = ./programs/formulas/examples/basic.nix;
        tests.basic.module = ./programs/formulas/tests/basic.nix;
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://github.com/vinci1it2000/formulas#installation";
        };
        test = {
          text = "Test instructions";
          url = "https://github.com/vinci1it2000/formulas/blob/v1.3.4/test";
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
          Run `formulas --help` to see available commands
        '';
      }
      {
        instruction = ''
          Visit https://formulas.readthedocs.io for full documentation
        '';
      }
    ];
    tests.demo.module = ./programs/formulas/tests/basic.nix;
  };
}
