{config, ...}: {
  services = {
    pretalx.settings.database.backend = "postgresql";

    postgresql = {
      enable = true;
      authentication = "local all all trust";
      ensureUsers = [
        {
          name = config.services.pretalx.settings.database.user;
          ensurePermissions."DATABASE \"${config.services.pretalx.settings.database.name}\"" = "ALL PRIVILEGES";
        }
      ];
      ensureDatabases = [config.services.pretalx.settings.database.name];
    };
  };
}
