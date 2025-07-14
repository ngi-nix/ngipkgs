{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "Holo is a suite of routing protocols designed to address the needs of modern networks";
    subgrants = [
      "HoloRouting"
    ];
  };

  nixos.modules.programs = {
    holo = {
      name = "holo";
      # if a project has `packages`, add them inside the `module.nix` file
      module = ./programs/holo/module.nix;
      examples."Enable the holo program" = {
        module = ./programs/holo/examples/basic.nix;
        tests.basic.module = import ./programs/holo/tests/basic.nix args;
      };
    };
  };

  nixos.modules.services = {
    holo-daemon = {
      name = "holo-daemon";
      module = ./services/holo/module.nix;
      examples."Enable the holo daemon service" = {
        module = ./services/holo/examples/holo.nix;
        tests.holo.module = import ./services/holo/tests/holo.nix args;
      };
    };
  };

  nixos.demo.vm = {
    module = ./services/holo/examples/holo.nix;
    description = ''
      A demo VM for testing Holo.

      First, we need to execute `holo-cli` with previliges because it changes the IP table and the network configuration:

      $ sudo holo-cli

      This will start a holo shell, inside which you need to run the following to set up an ospf protocol:

      - configure
      - routing control-plane-protocols control-plane-protocol ietf-ospf:ospfv3 main
      - ospf preference inter-area 50
      - show changes
      - commit
      - end
      - exit

      Finally, you can print and verify the routing configuration:

      $ holo-cli -c 'show running format json'
    '';
    tests.demo.module = import ./services/holo/tests/holo.nix args;
  };
}
