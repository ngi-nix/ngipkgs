{ pkgs, ... }:

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
    settings.database = "postgres";
    # Do *NOT* do this in production!
    databasePasswordFile = pkgs.writeText "postgresql-password" "nodebb";
  };

  # Do *NOT* do this in production!
  services.postgresql.initialScript = pkgs.writeText "init-sql-script" ''
    CREATE ROLE nodebb LOGIN PASSWORD 'nodebb';
  '';

  # demo-vm
  networking.firewall.allowedTCPPorts = [ 4567 ];
  services.getty.helpLine = ''
    NodeBB needs some time to set up and will list on port 4567 when ready.
    View journal with `journalctl -efu nodebb.sevice` to see progress.
  '';
}
