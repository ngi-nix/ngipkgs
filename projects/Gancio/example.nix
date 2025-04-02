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
    nginx = {
      enableACME = false;
      forceSSL = false;

    };
  };

}
