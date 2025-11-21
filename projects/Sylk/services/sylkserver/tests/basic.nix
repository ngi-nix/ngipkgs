{
  sources,
  lib,
  ...
}:

let
  ports = {
    sip = 5060;
    xmpp = 5269;
    web = 10888;
  };
in

{
  name = "Sylk (server)";
  meta.maintainers = lib.teams.ngi.members;

  nodes.machine =
    { config, ... }:
    {
      imports = [
        sources.modules.ngipkgs
        sources.modules.services.sylkserver
        sources.examples.Sylk."Enable Sylk (server)"
      ];

      services.sylkserver.settings.config.SIP.local_ip = "0.0.0.0";
      services.sylkserver.settings.config.SIP.local_tcp_port = ports.sip;

      services.sylkserver.settings.xmppgateway.general.local_ip = "0.0.0.0";
      services.sylkserver.settings.xmppgateway.general.local_port = ports.xmpp;

      # needed to correctly determine the system IP inside the sandbox
      networking.defaultGateway = config.networking.primaryIPAddress;
    };

  testScript =
    { nodes, ... }:
    # python
    ''
      machine.start()
      machine.wait_for_unit("sylkserver.service")
      machine.wait_for_open_port(${toString ports.sip})

      machine.succeed("curl -f http://${nodes.machine.networking.primaryIPAddress}:${toString ports.web}")
    '';

  # for debugging
  interactive.sshBackdoor.enable = true;
  interactive.nodes = {
    machine =
      { pkgs, lib, ... }:
      {
        # forward ports from VM to host
        virtualisation.forwardPorts = lib.mapAttrsToList (_: port: {
          from = "host";
          host = { inherit port; };
          guest = { inherit port; };
        }) ports;

        imports = [
          # enable graphical session + users (alice, bob)
          ./common/x11.nix
          ./common/user-account.nix
        ];

        services.xserver.enable = true;
        test-support.displayManager.auto.user = "alice";

        networking.firewall.enable = false;

        # TODO: connect client to server
        environment.systemPackages = with pkgs; [
          sylk
          freetalk
          pidgin
        ];
      };
  };
}
