{ ... }:

{
  services.zwm-server = {
    enable = true;
    settings = {
      port = 3000;
      # access point addresses
      aps = [
        "http://127.0.0.1:8003"
      ];
      ssids = [
        "Production"
      ];
    };
  };
}
