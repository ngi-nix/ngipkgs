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
          sources.modules.services.sstorytime
          sources.examples.SSTorytime."Enable SSTorytime"
        ];

        environment.systemPackages = with pkgs; [
          neovim
        ];

        services.postgresql = {
          enable = true;
          initialScript = pkgs.writeText "init-sql-script" ''
            CREATE USER sstoryline PASSWORD 'sst_1234' superuser;
            CREATE DATABASE sstoryline;
            GRANT ALL PRIVILEGES ON DATABASE sstoryline TO sstoryline;
            CREATE EXTENSION UNACCENT;
          '';
        };
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
        virtualisation.forwardPorts =
          (map
            (port: {
              from = "host";
              host.port = port;
              guest.port = port;
            })
            [
              config.services.postgresql.settings.port
            ]
          )
          ++ [
            {
              from = "host";
              host.port = 9090;
              guest.port = 8080;
            }
          ];

        # forwarded ports need to be accessible
        networking.firewall.enable = false;
      };
  };

  testScript =
    { nodes, ... }:
    # python
    ''
      start_all()

      machine.wait_for_unit("postgresql.service")
      machine.wait_for_unit("sstorytime.service")
      machine.wait_for_open_port(8080)

      machine.succeed("ln -s ${nodes.machine.services.sstorytime.package}/share/examples /tmp/examples")
      machine.succeed("N4L -u /tmp/examples/tutorial.n4l")
    '';
}
