{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Plugin System for the Ghidra Decompiler";
    subgrants.Entrust = [
      "ReOxide"
    ];
    links = {
      Website = {
        text = "Website";
        url = "https://reoxide.eu/";
      };
      source = {
        text = "Source repository";
        url = "https://codeberg.org/ReOxide";
      };
      documentation = {
        text = "Documentation";
        url = "https://reoxide.eu/guide/getting-started";
      };
    };
  };

  nixos.modules.programs = {
    reoxide = {
      name = "reoxide";
      module = ./programs/reoxide/module.nix;
      examples."Enable reoxide" = {
        module = ./programs/reoxide/examples/basic.nix;
        tests.basic.module = null;
      };
    };
  };

  nixos.modules.services = {
    reoxided = {
      name = "reoxided";
      module = ./services/reoxided/module.nix;
      examples."Enable reoxided" = {
        module = ./services/reoxided/examples/basic.nix;
        tests.basic.module = ./services/reoxided/tests/basic.nix;
      };
    };
  };
}
