{ ... }:
{
  services.openfire-server = {
    enable = true;
    openFirewall = true;
    servicePort = 9090;
    securePort = 9191;
  };
}
