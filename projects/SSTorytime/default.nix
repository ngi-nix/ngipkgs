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

  nixos.modules.services = {
    sstorytime = {
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
        tests.basic.module = import ./services/sstorytime/tests/basic.nix args;
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
}
