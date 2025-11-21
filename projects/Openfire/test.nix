{
  lib,
  pkgs,
  sources,
  ...
}:
{
  name = "Openfire server";

  nodes = {
    server =
      { lib, config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.openfire-server
          sources.examples.Openfire."Enable Openfire server"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    let
      port = toString nodes.server.services.openfire-server.servicePort;
    in
    ''
      start_all()

      server.wait_for_unit("openfire-server.service")
      server.wait_for_open_port(${port})

      server.succeed("curl -f http://localhost:${port}")
    '';

  # ssh -o User=root vsock/3
  interactive.sshBackdoor.enable = true;

  # nix run .#checks.x86_64-linux.projects/Openfire/nixos/tests/basic.driverInteractive -L
  # NOTE: diable `Restrict Admin Console Access` in the `Server Settings`, else you won't be able to login.
  interactive.nodes = {
    server =
      { config, ... }:
      {
        virtualisation.forwardPorts =
          let
            cfg = config.services.openfire-server;
          in
          [
            {
              from = "host";
              host.port = 2222;
              guest.port = 22;
            }
            {
              from = "host";
              host.port = cfg.servicePort;
              guest.port = cfg.servicePort;
            }
            {
              from = "host";
              host.port = cfg.securePort;
              guest.port = cfg.securePort;
            }
          ];
      };
  };
}
