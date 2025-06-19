{ config, pkgs, ... }:

{
  services.nodebb = {
    enable = true;
    enableLocalDB = true;
    admin = {
      username = "admin";
      email = "admin@example.com";
      # Do *NOT* do this in production!
      passwordFile = pkgs.writeText "nodebb-admin-password" "nodebb";
    };
    settings.database = "redis";
  };

  services.redis.servers."nodebb" = {
    port = 6379;
    # Do *NOT* do this in production!
    requirePassFile = pkgs.writeText "redis-password" "nodebb";
  };
}
