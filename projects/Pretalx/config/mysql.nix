{
  config,
  pkgs,
  ...
}: {
  services = {
    ngi-pretalx.database = {
      backend = "mysql";
      host = "/var/run/mysqld/mysqld.sock";
      user = "pretalx";
    };

    mysql = {
      enable = true;
      package = pkgs.mysql;
      ensureUsers = [
        {
          name = config.services.ngi-pretalx.database.user;
          ensurePermissions."${config.services.ngi-pretalx.database.name}.*" = "ALL PRIVILEGES";
        }
      ];
      ensureDatabases = [config.services.ngi-pretalx.database.name];
    };
  };
}
