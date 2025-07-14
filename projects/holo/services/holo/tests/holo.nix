{
  sources,
  ...
}:

{
  name = "holo";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.holo
          sources.modules.services.holo-daemon
          sources.examples.holo."Enable the holo daemon service"
        ];

        services.getty.autologinUser = "root";

      };
  };

  testScript =
    { nodes, ... }:
    ''

      import time

      start_all()

      # holo-cli connects to the daemon at startup
      # features a bash-like editing functionality for interactive use
      # uses -c option to execute arguments as commands

      machine.wait_for_unit("multi-user.target")
      machine.wait_for_unit("holo-daemon.service")
      machine.succeed("holo-cli -V")

      # wait for cli to connect to the daemon
      machine.wait_for_open_port(50051)

      # Test the running configuration is empty
      machine.succeed("holo-cli -c 'show running format json'")

      # Configure an OSPFv3 instance:
      # as seen in https://asciinema.org/a/qYxmDu1QjGPBAt5gNyNKvXhHk

      machine.send_chars("holo-cli\n")
      time.sleep(5)
      machine.send_chars("configure\n")
      machine.send_chars("routing control-plane-protocols control-plane-protocol ietf-ospf:ospfv3 main\n")
      machine.send_chars("ospf preference inter-area 50\n")
      machine.send_chars("show changes\n")
      machine.send_chars("commit\n")
      machine.send_chars("exit\n")

      # Verify the configuration was applied (in interactive test)
      machine.succeed("test \"$(holo-cli -c 'show running format json')\" != \"{}\"");
    '';
}
