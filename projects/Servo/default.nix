{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Embeddable, independent, memory-safe, modular, parallel web rendering engine";
    subgrants = {
      Entrust = [
        "Servo"
        "Servo-CSS"
      ];
      Commons = [
        "Servo-Editability"
        "Servo-ServiceWorker-WebAPI"
      ];
      Core = [
        "Servo-Benchmark"
        "Servo-Script"
        "Servo-Multiprocess"
      ];
      Review = [
        "Servo-DX"
        "Servo-Multibrowsing"
      ];
    };
  };

  nixos.modules.programs = {
    servo = {
      module = ./module.nix;
      examples.basic = {
        module = ./example.nix;
        description = "Enable the servo program";
        tests.basic.module = pkgs.nixosTests.servo;
      };
    };
  };

  nixos.demo.shell = {
    module = ./example.nix;
    module-demo = ./module-demo.nix;
    description = "A demo shell for opening valgrind docs with Servo";
    tests.basic.module = pkgs.nixosTests.servo;
  };
}
