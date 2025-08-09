{ lib, ... }:

{
  services.timesyncd.enable = lib.mkForce false;

  services.ntpd-rs = {
    enable = true;
    useNetworkingTimeServers = false;

    settings.source = (
      map
        (s: {
          mode = "nts";
          address = s;
        })
        [
          "brazil.time.system76.com"
          "ohio.time.system76.com"
          "oregon.time.system76.com"
          "paris.time.system76.com"
          "virginia.time.system76.com"
        ]
    );
  };
}
