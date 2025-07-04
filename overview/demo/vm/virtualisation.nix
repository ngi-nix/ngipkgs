{ config, ... }:
{
  virtualisation = {
    memorySize = 4096;
    diskSize = 4096;
    cores = 4;
    graphics = false;

    qemu.options = [
      "-cpu host"
      "-enable-kvm"
    ];

    # ssh + open service ports
    forwardPorts = map (port: {
      from = "host";
      guest.port = port;
      host.port = port;
      proto = "tcp";
    }) config.networking.firewall.allowedTCPPorts;
  };
}
