{ config, ... }:
{
  services.cryptpad = {
    enable = true;
    openPorts = true;

    settings = {
      httpPort = 9000;
      httpAddress = "0.0.0.0";
      httpUnsafeOrigin = "http://localhost:${toString config.services.cryptpad.settings.httpPort}";
      httpSafeOrigin = "http://localhost:${toString config.services.cryptpad.settings.httpPort}";
    };
  };
}
