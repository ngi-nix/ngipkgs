{ ... }:
let
  servicePort = 9000;
  domainName = "localhost:${toString servicePort}";
in
{
  services.cryptpad = {
    enable = true;
    settings = {
      httpPort = servicePort;
      httpUnsafeOrigin = "http://${domainName}";
      httpSafeOrigin = "http://${domainName}";
    };
  };

  networking.firewall.allowedTCPPorts = [ servicePort ];
  networking.firewall.allowedUDPPorts = [ servicePort ];
}
