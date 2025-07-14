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
        tests.basic.module = pkgs.nixosTests.oku;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/oku/examples/basic.nix;
    description = ''
      A demo for testing Oku, a browser designed to use IPFS

      Open oku and enter your favorite website into the URL.

      Alternatively, run:

      $ oku -n 'https://www.fsf.org'
    '';

    tests.basic.module = pkgs.nixosTests.oku;
  };
}
