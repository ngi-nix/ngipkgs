{ pkgs, ... }:

{
  # ACME
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@example.com";
    };
  };

  # Nominatim
  services.nominatim = {
    enable = true;
    hostName = "nominatim";
    ui = {
      config = ''
        Nominatim_Config.Page_Title='Nominatim demo instance';
        Nominatim_Config.Nominatim_API_Endpoint='https://localhost:8443/';
      '';
    };
  };

  environment.systemPackages = [ pkgs.wget ];

  services.nginx.defaultSSLListenPort = 8443;
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
