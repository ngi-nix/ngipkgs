{ pkgs, ... }:

{
  services.nodebb = {
    enable = true;
    enableLocalDB = true;
    openFirewall = true;
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
  programs.bash.interactiveShellInit = ''
    echo "NodeBB is starting. Please wait ..."
    until systemctl show nodebb.service | grep -q ActiveState=active; do sleep 1; done
    echo "NodeBB is ready at http://localhost:4567"
  '';
}
