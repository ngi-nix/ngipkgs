{ config, pkgs, ... }:

{
  services.nodebb = {
    enable = true;
    admin = {
      username = "admin";
      email = "admin@example.com";
      # Do *NOT* do this in production!
      passwordFile = pkgs.writeText "nodebb-admin-password" "nodebb";
    };
    settings.database = "redis";
    databasePasswordFile = config.services.redis.servers."nodebb".requirePassFile;
  };

  systemd.services.nodebb.after = [ "redis-nodebb.service" ];

  services.redis.servers."nodebb" = {
    enable = true;
    port = 6379;
    # Do *NOT* do this in production!
    requirePassFile = pkgs.writeText "redis-password" "nodebb";
  };
}
