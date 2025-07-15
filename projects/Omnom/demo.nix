let
  port = 8080;
in
{
  services.omnom = {
    enable = true;
    openFirewall = true;
    inherit port;
    settings = {
      server.address = "0.0.0.0:${toString port}";
    };
  };
}
