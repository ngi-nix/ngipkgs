{...}: {
  networking.firewall.allowedTCPPorts = [80];

  services = {
    kbin = {
      enable = true;
      # settings.APP_DEBUG = "1";
    };

    postgresql = {
      enable = true;
      authentication = "host all all 127.0.0.1/32 trust";
      ensureUsers = [
        {
          name = "kbin";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = ["kbin"];
      enableTCPIP = true;
    };
  };
}
