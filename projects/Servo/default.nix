{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Embeddable, independent, memory-safe, modular, parallel web rendering engine";
    subgrants = [
      "Servo"
      "Servo-Benchmark"
      "Servo-CSS"
      "Servo-DX"
      "Servo-Multibrowsing"
      "Servo-Script"
      "Servo-Multiprocess"
    ];
  };

  nixos.modules.programs = {
    servo = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "Enable the servo program";
        tests.basic.module = pkgs.nixosTests.servo;
        tests.basic.problem.broken.reason = ''
          Servo fails to build because of incompatabilities with Rust 1.89

          See https://github.com/NixOS/nixpkgs/issues/439547
        '';
      };
    };
  };

  nixos.demo.shell = {
    module = ./example.nix;
    description = "A demo shell for opening valgrind docs with Servo";
    tests.basic.module = pkgs.nixosTests.servo;
    tests.basic.problem.broken.reason = ''
      Servo fails to build because of incompatabilities with Rust 1.89

      See https://github.com/NixOS/nixpkgs/issues/439547
    '';
  };
}
