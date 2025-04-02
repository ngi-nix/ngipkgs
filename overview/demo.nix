{
  ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/main") { },
}:
let
  servicePort = 9000;
  domainName = "localhost:${toString servicePort}";
in
ngipkgs.demo {
  services.cryptpad = {
    enable = true;
    settings = {
      httpPort = servicePort;
      httpAddress = "0.0.0.0";
      httpUnsafeOrigin = "http://${domainName}";
      httpSafeOrigin = "http://${domainName}";
    };
  };

  networking.firewall.allowedTCPPorts = [ servicePort ];
  networking.firewall.allowedUDPPorts = [ servicePort ];
}
