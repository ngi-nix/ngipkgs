{ ... }:
{
  services = {
    galene = {
      enable = true;
      httpport = 8443;
      certfile = "etc/galene/cert.pem";
      keyfile = "etc/galene/keyfile.pem";
    };
  }
}
