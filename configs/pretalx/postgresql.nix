{config, ...}: {
  services = {
    pretalx.database.backend = "postgresql";

    postgresql = {
      enable = true;
      authentication = "local all all trust";
      ensureUsers = [
        {
          name = config.services.pretalx.database.user;
          ensurePermissions."DATABASE \"${config.services.pretalx.database.name}\"" = "ALL PRIVILEGES";
        }
      ];
      ensureDatabases = [config.services.pretalx.database.name];
    };
  };
}
