{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Visual developer tool for development of FPGAs";
    subgrants = [
      "Icestudio"
    ];
    links = {
      website = {
        text = "Icestudio Website";
        url = "https://icestudio.io/";
      };
    };
  };

  nixos.modules.programs = {
    icestudio = {
      name = "icestudio";
      module = ./programs/Icestudio/module.nix;
      examples.basic = {
        module = ./programs/Icestudio/examples/basic.nix;
        description = "";
        tests.basic = import ./programs/Icestudio/tests/basic.nix args;
      };
      links = {
        build = {
          text = "Installation";
          url = "https://github.com/FPGAwars/icestudio/wiki/Installation";
        };
        docs = {
          text = "Documentation";
          url = "https://github.com/FPGAwars/icestudio/wiki/";
        };
      };
    };
  };
}
