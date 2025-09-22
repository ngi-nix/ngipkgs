{
  sources,
  lib,
  ...
}:
let
  sharedConfig = {
    imports = [
      sources.modules.ngipkgs
      sources.modules.services.ratmand
      sources.examples.Irdest.basic-ratmand
    ];

    # ratmand inet driver
    networking.firewall.allowedTCPPorts = [ 5860 ];

    # ratmand fails to allocate all of its memory with only 1024
    virtualisation.memorySize = 1536;
  };

  serverIP = "192.168.2.10";
  clientIP = "192.168.2.11";
in
{
  name = "ratmand-peer-communication";

  nodes = {
    server = lib.recursiveUpdate sharedConfig {
      networking.interfaces.eth1 = {
        ipv4.addresses = [
          {
            address = serverIP;
            prefixLength = 24;
          }
        ];
      };
      services.ratmand.settings.ratmand.accept_unknown_peers = true;
    };
    client = lib.recursiveUpdate sharedConfig {
      networking.interfaces.eth1 = {
        ipv4.addresses = [
          {
            address = clientIP;
            prefixLength = 24;
          }
        ];
      };
      services.ratmand.settings.ratmand.peers = [ "inet:${serverIP}:5860" ];
    };
  };

  testScript =
    { nodes, ... }:
    ''
      server.start()
      server.wait_for_unit("ratmand.service")
      server.wait_for_console_text("Listening to API socket")
      server.sleep(3)

      client.start()
      client.wait_for_unit("ratmand.service")
      client.wait_for_console_text("Listening to API socket")
      client.sleep(3)

      server.succeed("ratctl addr create", "ratctl addr up")
      server_address = server.succeed("ratctl addr list").strip()
      server.succeed("ratcat recv > ratcat_output &")

      client.succeed("ratctl addr create", "ratctl addr up")
      client.succeed("echo 'Greetings my trusty VM compatriot!' | "
                    f"ratcat send --addr {server_address}")
      server.wait_until_succeeds(
        "cat ratcat_output | grep 'Greetings my trusty VM compatriot!'"
      )
    '';
}
