{
  lib,
  pkgs,
  sources,
  ...
}:
{
  # NOTE:
  # - Run the test interactively to access the server: nix run .#nixosTests.Openfire-IPv6.openfire-server.driverInteractive
  # - Diable `Restrict Admin Console Access` in the `Server Settings`, else you won't be able to login.

  name = "openfire";
  meta = {
    maintainers = [ ];
  };

  nodes = {
    server =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.openfire-server
        ];

        services.openfire-server = {
          enable = true;
          openFirewall = true;
        };

        services.openssh = {
          enable = true;
          settings = {
            PermitRootLogin = "yes";
            PermitEmptyPasswords = "yes";
          };
        };
        security.pam.services.sshd.allowNullPassword = true;

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

  testScript = ''
    start_all()
    server.wait_for_unit("openfire-server.service")
    server.wait_for_open_port(9090)
  '';
}
