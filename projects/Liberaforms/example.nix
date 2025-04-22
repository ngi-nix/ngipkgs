{ ... }:
{
  services.liberaforms = {
    enable = true;
    enablePostgres = true;
    enableNginx = true;
    domain = "localhost";
  };

  time.timeZone = "Europe/Paris";
}
