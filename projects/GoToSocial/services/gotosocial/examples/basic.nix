{ ... }:
{
  services.gotosocial = {
    enable = true;
    setupPostgresqlDB = true;
    settings = {
      application-name = "My GoToSocial";
      host = "gotosocial.example.com";
      protocol = "http";
      bind-address = "127.0.0.1";
      port = 8080;
    };
  };
}
