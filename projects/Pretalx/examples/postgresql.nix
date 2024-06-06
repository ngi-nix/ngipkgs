{config, ...}: {
  services = {
    ngi-pretalx.database = {
      backend = "postgresql";
      user = "pretalx";
    };

    postgresql = {
      enable = true;
      authentication = "local all all trust";
      ensureUsers = [
        {
          name = config.services.ngi-pretalx.database.user;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [config.services.ngi-pretalx.database.name];
    };
  };
}
