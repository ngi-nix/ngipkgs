{ ... }:

{
  services.manyfold = {
    enable = true;
    settings = {
      # Do *NOT* do this in production!
      SECRET_KEY_BASE = "0123456789abcdef0123456789abcdef";
      DATABASE_ADAPTER = "sqlite3";
      DATABASE_NAME = "/var/lib/manyfold/manyfold.sqlite3";
    };
  };

  services.redis.servers.manyfold.port = 6379;
}
