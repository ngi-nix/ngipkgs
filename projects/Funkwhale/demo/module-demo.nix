{
  config,
  lib,
  ...
}:
{
  services.funkwhale = {
    settings = {
      FUNKWHALE_API_IP = "0.0.0.0";
      FUNKWHALE_HOSTNAME = lib.mkForce "localhost:12345";
    };
  };

  services.nginx.virtualHosts.${config.services.funkwhale.settings.FUNKWHALE_HOSTNAME}.listen = [
    {
      addr = "0.0.0.0";
      port = 12345;
    }
  ];

  networking.firewall.allowedTCPPorts = [ 12345 ];
}
