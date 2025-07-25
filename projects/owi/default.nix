{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Cross-language symbolic execution for C, C++, Rust, Zig, and Wasm";
    subgrants = [
      "OWI"
      "Owi-2"
    ];
  };

  nixos.modules.programs = {
    owi = {
      name = "owi";
      module = ./programs/owi/module.nix;
      examples.basic = {
        module = ./programs/owi/examples/basic.nix;
        description = "Enable the owi program";
        tests.basic.module = pkgs.nixosTests.owi;
      };
    };
  };

  nixos.demo.shell = {
    module = ./programs/owi/examples/basic.nix;
    description = "owi usage example";
    tests.basic.module = pkgs.nixosTests.owi;
  };
}
