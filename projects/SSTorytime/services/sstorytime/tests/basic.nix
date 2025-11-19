{
  pkgs,
  sources,
  ...
}:

{
  name = "SSTorytime basic test";

  nodes = {
    machine =
      { config, pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.sstorytime
          sources.modules.services.sstorytime
          sources.examples.SSTorytime."Enable SSTorytime programs"
          sources.examples.SSTorytime."Enable SSTorytime server"
        ];
      };
  };

  # Debug interactively with:
  # - nix run .#checks.x86_64-linux.projects/SSTorytime/nixos/tests/basic.driverInteractive -L
  # - run_tests()
  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock/3
  interactive.nodes = {
    machine =
      {
        lib,
        config,
        ...
      }:
      {
        # forward ports from VM to host
        virtualisation.forwardPorts = [
          {
            from = "host";
            host.port = config.services.sstorytime.port;
            guest.port = config.services.sstorytime.port;
          }
        ];

        # forwarded ports need to be accessible
        networking.firewall.enable = false;
      };
  };

  testScript =
    { nodes, ... }:
    let
      cfg = nodes.machine.services.sstorytime;
    in
    # python
    ''
      start_all()

      machine.wait_for_unit("sstorytime.service")
      machine.wait_for_open_port(${toString cfg.port})

      machine.succeed("ln -s ${cfg.package}/share/examples /tmp/examples")

      # index and upload test file to database
      machine.succeed("N4L -v -u /tmp/examples/SSTorytime.n4l")

      # search for term in graph
      output = machine.succeed("searchN4L -v SSTorytime")
      assert "notes about SSTorytime in N4L" in output, "Failed to search for term in graph."

      # get relation sub-graph
      output = machine.succeed('N4L -s -adj="pe" /tmp/examples/chinese.n4l')
      assert "Incidence summary of raw declarations" in output, "Failed to get relation sub-graph."

      # summarize graph
      output = machine.succeed('N4L -s -adj="" /tmp/examples/Mary.n4l')
      assert "Incidence summary of raw declarations" in output, "Failed to summarize graph."
    '';
}
