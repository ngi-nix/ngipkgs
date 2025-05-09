{ ... }:
{
  services = {
    galene = {
      enable = true;
      httpPort = 8443;
      certFile = "/etc/galene/cert.pem";
      keyFile = "/etc/galene/keyfile.pem";
    };
  };
}
