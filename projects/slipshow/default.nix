{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Slipshow is an innovative presentation tool that moves away from the traditional slide-based approach";
    subgrants.Commons = [
      "Slipshow"
    ];
  };

  nixos.modules.programs = {
    slipshow = {
      name = "slipshow";
      module = ./programs/slipshow/module.nix;
      examples.basic = {
        module = ./programs/slipshow/examples/basic.nix;
        description = "Enable the slipshow program";
        tests.basic.module = pkgs.nixosTests.slipshow;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/slipshow/examples/basic.nix;
    module-demo = ./module-demo.nix;
    description = "slipshow example";
    tests.basic.module = pkgs.nixosTests.slipshow;
  };
}
