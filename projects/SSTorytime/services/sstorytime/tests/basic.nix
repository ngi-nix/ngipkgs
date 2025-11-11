{
  pkgs,
  sources,
  ...
}:

{
  name = "Serivce Name";

  nodes = {
    machine =
      { config, pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          # sources.modules.services._serviceName_
          # sources.examples._ProjectName_._exampleName_
        ];

        environment.systemPackages = with pkgs; [
          neovim
          sstorytime
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

      machine.succeed("ln -s ${pkgs.sstorytime}/share/examples /tmp/examples")
      machine.succeed("ln -s ${pkgs.sstorytime}/share/config/SSTconfig /tmp/SSTconfig")
      machine.succeed('\
        SST_CONFIG_PATH="${pkgs.sstorytime}/share/config/SSTconfig" \
        N4L -u \
        ${pkgs.sstorytime}/share/examples/tutorial.n4l \
      ')

      machine.succeed("http_server")
    '';
}
