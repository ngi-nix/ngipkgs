{ config, ... }:
{
  services.cryptpad = {
    enable = true;
    openPorts = true;

    settings = {
      httpPort = 9000;
      httpAddress = "0.0.0.0";
      httpUnsafeOrigin = "http://localhost:19000";
      httpSafeOrigin = "http://localhost:19000";
    };
  };
}
