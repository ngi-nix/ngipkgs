{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Tool to help modeling engineers extract model parameters, run circuit and TCAD simulations and automate infrastructure";
    subgrants.Entrust = [
      "DMT-Core"
    ];
  };

  nixos.modules.programs = {
    dmt-core = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "";
        tests.basic.module = null;
      };
      links = {
        test = {
          text = "Test Cases and Examples";
          url = "https://dmt-development.gitlab.io/dmt-core/examples/index.html";
        };
      };
    };
  };
}
