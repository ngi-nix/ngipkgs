{ ... }:
let
  servicePort = 9000;
in
{
  services.cryptpad = {
    enable = true;
    settings = {
      httpPort = servicePort;
      httpUnsafeOrigin = "http://localhost:${toString servicePort}";
      httpSafeOrigin = "http://localhost:${toString servicePort}";
    };
  };

  networking.firewall.allowedTCPPorts = [ servicePort ];
  networking.firewall.allowedUDPPorts = [ servicePort ];
}
