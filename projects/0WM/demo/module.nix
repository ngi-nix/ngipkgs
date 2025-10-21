{ lib, ... }:

{
  programs.zwm-client.enable = true;
  services.zwm-server = {
    enable = true;
    openFirewall = true;
    settings = {
      port = 3000;
      aps = [
        "http://127.0.0.1:8003" # mock access point
      ];
      ssids = [
        "Production"
      ];
    };
  };
}
