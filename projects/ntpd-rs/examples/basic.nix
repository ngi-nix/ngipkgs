{ lib, ... }:

{
  services.timesyncd.enable = lib.mkForce false;

  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;

    settings = {
      synchronization.minimum-agreeing-sources = 1;
      source = [
        {
          mode = "server";
          address = "time.cloudflare.com";
        }
      ];
    };
  };
}
