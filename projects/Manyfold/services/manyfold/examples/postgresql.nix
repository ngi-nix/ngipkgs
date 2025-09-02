{ config, pkgs, ... }:

{
  services.manyfold = {
    enable = true;
    settings = {
      # Do *NOT* do this in production!
      SECRET_KEY_BASE = "0123456789abcdef0123456789abcdef";
      DATABASE_ADAPTER = "postgresql";
      DATABASE_HOST = "127.0.0.1";
      DATABASE_PORT = toString config.services.postgresql.settings.port;
      # Do *NOT* do this in production!
      DATABASE_USER = "manyfold";
      DATABASE_PASSWORD = "manyfold";
      DATABASE_NAME = "manyfold";
    };
  };

  services.redis.servers.manyfold.port = 6379;

  systemd.services.manyfold.after = [ "postgresql.service" ];
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "manyfold" ];
    ensureUsers = [
      {
        name = "manyfold";
        ensureDBOwnership = true;
      }
    ];
    # Do *NOT* do this in production!
    initialScript = pkgs.writeText "init-sql-script" ''
      CREATE ROLE manyfold LOGIN PASSWORD 'manyfold';
    '';
  };
}
