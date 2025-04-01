{
  pkgs,
  ...
}:
{
  services.gancio = {
    enable = true;
    plugins = [ pkgs.gancioPlugins.telegram-bridge ];
    settings = {
      hostname = "agenda.example.org";
      #postgress is available as well
      db.dialect = "sqlite";
    };
  };
  security.acme.acceptTerms = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  security.acme.defaults.email = "info@cisti.org";
}
