{
  config,
  lib,
  pkgs,
  ...
}:
{

  services.cryptpad = {
    enable = true;
    configureNginx = true;
    settings = {
      httpUnsafeOrigin = "https://cryptpad.localhost";
      httpSafeOrigin = "https://cryptpad-sandbox.localhost";
    };
  };

  services.nginx = {
    virtualHosts."cryptpad.localhost" = {
      enableACME = false;
      forceSSL = false;
    };
  };

}
