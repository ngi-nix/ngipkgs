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

        # TODO: remove
        environment.systemPackages = with pkgs; [
          neovim
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
            host.port = 9090;
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

      machine.wait_for_unit("postgresql.service")
      machine.wait_for_unit("sstorytime.service")
      machine.wait_for_open_port(${toString cfg.port})

      machine.succeed("ln -s ${cfg.package}/share/examples /tmp/examples")
      machine.succeed("N4L -u /tmp/examples/tutorial.n4l")
    '';
}
