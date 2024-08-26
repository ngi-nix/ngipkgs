{...}: {
  networking.firewall.allowedTCPPorts = [80];

  services = {
    atomic-server = {
      enable = true;
    };
  };
}
