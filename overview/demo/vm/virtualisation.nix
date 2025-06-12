{ config, ... }:
{
  virtualisation = {
    graphics = false;

    # ssh + open service ports
    forwardPorts = map (port: {
      from = "host";
      guest.port = port;
      host.port = port;
      proto = "tcp";
    }) config.networking.firewall.allowedTCPPorts;
  };
}
