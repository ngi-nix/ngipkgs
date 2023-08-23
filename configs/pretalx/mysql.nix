{
  config,
  pkgs,
  ...
}: {
  services = {
    pretalx.database = {
      backend = "mysql";
      host = "/var/run/mysqld/mysqld.sock";
    };

    mysql = {
      enable = true;
      package = pkgs.mysql;
      ensureUsers = [
        {
          name = config.services.pretalx.database.user;
          ensurePermissions."${config.services.pretalx.database.name}.*" = "ALL PRIVILEGES";
        }
      ];
      ensureDatabases = [config.services.pretalx.database.name];
    };
  };
}
