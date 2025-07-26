{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Oku is a browser and encrypted data vault based on IPFS";
    subgrants = [
      "Oku"
    ];
  };

  nixos.modules.programs = {
    oku = {
      name = "oku";
      module = ./programs/oku/module.nix;
      examples."Enable Oku" = {
        module = ./programs/oku/examples/basic.nix;
        tests.basic.module = import ./programs/oku/tests/shell.nix args;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/oku/examples/basic.nix;
    description = "oku demo";
    tests.basic.module = import ./programs/oku/tests/shell.nix args;
  };
}
