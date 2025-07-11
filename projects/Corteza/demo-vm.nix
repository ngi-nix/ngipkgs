let
  port = 8090;
in
{
  services.corteza = {
    enable = true;
    inherit port;
    openFirewall = true;
    settings.DOMAIN = "localhost:${toString port}";
  };
}
