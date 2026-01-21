{ lib, config, ... }:
{
  virtualisation = {
    memorySize = 4096;
    diskSize = 4096;
    cores = 4;
    graphics = lib.mkIf (!config.services.xserver.enable) false;

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

    # allows Nix commands to re-use and write to the host's store
    mountHostNixStore = true;
    writableStoreUseTmpfs = false;
  };

  # better integration with the desktop
  services.spice-vdagentd.enable = lib.mkIf config.virtualisation.graphics true;
}
