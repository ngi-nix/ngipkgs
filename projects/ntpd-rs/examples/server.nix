# example extracted from official NixOS test
# https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/ntpd-rs.nix
{
  networking.firewall = {
    allowedTCPPorts = [ 9975 ];
    allowedUDPPorts = [ 123 ];
  };

  services.ntpd-rs = {
    enable = true;
    metrics.enable = true;
    settings = {
      observability.metrics-exporter-listen = "[::]:9975";
      server = [ { listen = "[::]:123"; } ];
    };
  };
}
