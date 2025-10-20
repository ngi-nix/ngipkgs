{
  services.funkwhale = {
    enable = true;
    configureNginx = true;
    settings = {
      FUNKWHALE_HOSTNAME = "localhost";
    };
  };
}
