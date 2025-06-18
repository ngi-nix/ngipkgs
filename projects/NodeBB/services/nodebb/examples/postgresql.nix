{ pkgs, ... }:

{
  services.nodebb = {
    enable = true;
    admin = {
      username = "admin";
      email = "admin@example.com";
      # Do *NOT* do this in production!
      passwordFile = pkgs.writeText "nodebb-admin-password" "nodebb";
    };
    settings.database = "postgres";
    # Do *NOT* do this in production!
    databasePasswordFile = pkgs.writeText "postgresql-password" "nodebb";
  };

  systemd.services.nodebb.after = [ "postgresql.service" ];

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nodebb" ];
    ensureUsers = [
      {
        name = "nodebb";
        ensureDBOwnership = true;
      }
    ];
    # Do *NOT* do this in production!
    initialScript = pkgs.writeText "init-sql-script" ''
      CREATE ROLE nodebb LOGIN PASSWORD 'nodebb';
    '';
  };
}
