{
  lib,
  pkgs,
  sources,
}@args:

{
  metadata = {
    summary = "Jaq is a data wrangling tool focusing on correctness, speed, and simplicity";
    subgrants = [
        "jaq"
        "Polyglot-jaq"
    ];
  };

  nixos.modules.programs = {
    jaq = {
      name = "jaq";
      module = ./programs/jaq/module.nix;
      examples.basic = {
        module = ./programs/jaq/examples/basic.nix;
        description = "Enable the jaq program";
        tests.basic = import ./programs/jaq/tests/basic.nix args;
      };
    };
  };

  # no service module as this is strictly a program
}
