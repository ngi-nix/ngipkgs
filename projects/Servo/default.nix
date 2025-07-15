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
        description = "";
        tests.basic.module = null;
      };
    };
  };
}
