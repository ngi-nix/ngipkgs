{
  pkgs,
  ...
}:
{
  services.gancio = {
    enable = true;

    settings = {
      hostname = "agenda.example.org";
      # postgress is available as well
      db.dialect = "sqlite";
    };

    plugins = with pkgs.gancioPlugins; [
      telegram-bridge
    ];

    nginx = {
      enableACME = false;
      forceSSL = false;
    };
  };
}
