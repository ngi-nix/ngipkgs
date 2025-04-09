{
  config,
  pkgs,
  ...
}:

let
  dbUser = "marginalia";

  # The way the password is used here, and how files that depend on it get generated & put into the store, is...
  # ! NOT SECURE !
  # ... For production usage, look into secrets management via Nix.
  dbPassword = "foobar";

  # This is hardcoded in marginalia
  dbTable = "WMSA_prod";
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [
      dbTable
    ];
    settings = {
      mysqld = {
        bind-address = "127.0.0.1";
        port = "3306";
      };
      mariadb = {
        plugin_load_add = "auth_ed25519";
      };
    };
    # ensureUsers sets wrong password type, we need simple password login
    # The way the password is used here, and how files that depend on it get generated & put into the store, is...
    # ! NOT SECURE !
    # ... For production usage, look into secrets management via Nix.
    initialScript = pkgs.writeText "initial-mariadb-script" ''
      CREATE USER IF NOT EXISTS '${dbUser}'@'localhost' IDENTIFIED WITH ed25519;
      ALTER USER '${dbUser}'@'localhost' IDENTIFIED BY '${dbPassword}';
      GRANT ALL PRIVILEGES ON ${dbTable}.* TO '${dbUser}'@'localhost';
    '';
  };

  services.zookeeper = {
    enable = true;
    port = 2181;
  };

  services.marginalia-search = {
    enable = true;
    systemProperties = {
      "crawler.userAgentString" = "Mozilla/5.0 (compatible)";
      "crawler.userAgentIdentifier" = "GoogleBot";
      "crawler.poolSize" = "256";

      "log4j2.configurationFile" = "log4j2-test.xml";

      "search.websiteUrl" = "http://localhost:8080";

      "executor.uploadDir" = "/uploads";
      "converter.sideloadThreshold" = "10000";

      "ip-blocklist.disabled" = "false";
      "blacklist.disable" = "false";
      "flyway.disable" = "false";
      "control.hideMarginaliaApp" = "false";

      "zookeeper-hosts" = "localhost:${toString config.services.zookeeper.port}";

      "storage.root" = "/var/lib/marginalia-search/index-1";
    };
    # The way the password is used here, and how files that depend on it get generated & put into the store, is...
    # ! NOT SECURE !
    # ... For production usage, look into secrets management via Nix.
    dbPropertiesFile = "${(pkgs.formats.javaProperties { }).generate "db.properties" {
      "db.user" = "${dbUser}";
      "db.pass" = "${dbPassword}";
      "db.conn" =
        "jdbc:mariadb://${config.services.mysql.settings.mysqld.bind-address}:${toString config.services.mysql.settings.mysqld.port}/${dbTable}?rewriteBatchedStatements=true";
    }}";
  };

}
