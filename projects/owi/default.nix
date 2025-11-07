{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Cross-language symbolic execution for C, C++, Rust, Zig, and Wasm";
    subgrants = {
      Commons = [
        "Owi-2"
      ];
      Core = [
        "OWI"
      ];
    };
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
    module-demo = ./module-demo.nix;
    description = "owi usage example";
    tests.basic.module = pkgs.nixosTests.owi;
  };
}
