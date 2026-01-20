{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Python module to manage 3DTiles format.";
    subgrants = {
      Core = [ "Py3DTiles" ];
    };
    links = {
      repo = {
        text = "Repository";
        url = "https://gitlab.com/py3dtiles/py3dtiles";
      };
      homepage = {
        text = "Home Page";
        url = "https://py3dtiles.org";
      };
      docs = {
        text = "Documentation";
        url = "https://py3dtiles.org/main";
      };
    };
  };

  nixos.modules.programs = {
    py3dtiles = {
      name = "py3dtiles";
      module = ./programs/py3dtiles/module.nix;
      examples.basic = {
        module = ./programs/py3dtiles/examples/basic.nix;
        tests.basic.module = ./programs/py3dtiles/tests/basic.nix;
      };
      links = {
        build = {
          text = "Build from source";
          url = "https://py3dtiles.org/main/install.html#from-sources";
        };
        test = {
          text = "Test instructions";
          url = "https://py3dtiles.org/main/install.html#from-sources";
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
          Run `py3dtiles` in the terminal
        '';
      }
    ];
    tests.demo.module = ./programs/py3dtiles/tests/basic.nix;
  };
}
