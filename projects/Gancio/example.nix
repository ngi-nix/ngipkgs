{
  pkgs,
  ...
}:
{
  services.gancio = {
    enable = true;
    package = pkgs.gancio;
    plugins = [ pkgs.gancioPlugins.telegram-bridge ];
    settings = {
      hostname = "agenda.example.org";
      db.dialect = "postgres";
    };
  };
  security.acme.acceptTerms = true;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  security.acme.defaults.email = "info@cisti.org";
}
