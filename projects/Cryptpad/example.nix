{ ... }:
{
  services.cryptpad = {
    enable = true;
    settings = rec {
      httpPort = 9000;
      httpUnsafeOrigin = "http://localhost:${toString httpPort}";
      httpSafeOrigin = "https://cryptpad.example.com";
    };
  };
}
