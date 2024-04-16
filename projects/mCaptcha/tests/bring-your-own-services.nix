{sources, ...}: let
  port = 7000;
  urlRoot = "http://localhost:${builtins.toString port}";
  redisPassword = "(*&(*):ps@r}";
in {
  name = "test of mcaptcha with database and other services running on a different node";

  nodes.mcaptcha = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      sources.modules.default
      sources.modules."mCaptcha/service"
    ];

    services.mcaptcha.enable = true;
    services.mcaptcha.settings.server.port = port;
    services.mcaptcha.settings.server.domain = "localhost";
    services.mcaptcha.server.cookieSecretFile = pkgs.writeText "cookie-secret" "mcaptcha-cookie-secret-dm0tdGVzdC1ydW4tbWNhcHRjaGEtdGVzdHM";
    services.mcaptcha.captcha.saltFile = pkgs.writeText "salt" "asdl;kjfhjawehfpa;osdkjasdvjaksndfpoanjdfainsdfaijdsfajlkjdsaf;ajsdfweroire";

    services.mcaptcha.settings.database.name = "my_mcaptcha";
    services.mcaptcha.settings.database.username = "role_mcaptcha";
    services.mcaptcha.settings.database.hostname = "my_own_services";
    services.mcaptcha.settings.database.port = 5432;
    services.mcaptcha.database.passwordFile = pkgs.writeText "db-password" "mcaptcha-db-secret";

    services.mcaptcha.redis.passwordFile = pkgs.writeText "redis-secret" redisPassword;
    services.mcaptcha.redis.host = "my_own_services";
  };

  nodes.my_own_services = {pkgs, ...}: {
    imports = [
      sources.modules.default
    ];
    networking.firewall.enable = false;
    services.postgresql.enable = true;
    services.postgresql.enableTCPIP = true;
    services.postgresql.initialScript = pkgs.writeText "postgresql-init-script" ''
      CREATE ROLE role_mcaptcha WITH LOGIN PASSWORD 'mcaptcha-db-secret';
      CREATE DATABASE my_mcaptcha;
      GRANT ALL PRIVILEGES ON DATABASE my_mcaptcha TO role_mcaptcha;
    '';
    services.postgresql.authentication = ''
      #type  database  DBuser         auth-method
      host   all       all 0.0.0.0/0  md5
    '';
    services.redis.servers.mcaptcha.enable = true;
    services.redis.servers.mcaptcha.port = 6379;
    services.redis.servers.mcaptcha.bind = null;
    services.redis.servers.mcaptcha.extraParams = [
      "--loadmodule"
      "${pkgs.mcaptcha-cache}/lib/libcache.so"
    ];
    services.redis.servers.mcaptcha.requirePass = redisPassword;
  };

  testScript = {nodes, ...}: ''
    import json

    my_own_services.start()
    my_own_services.wait_for_unit("redis-mcaptcha.service")
    my_own_services.wait_for_unit("postgresql.service")

    mcaptcha.start()

    mcaptcha.wait_for_unit("mcaptcha.service")
    mcaptcha.wait_until_succeeds("curl --fail --connect-timeout 2 ${urlRoot}", timeout=60)

    mcaptcha.succeed("curl --fail --connect-timeout 10 ${urlRoot}/widget")

    json_str = mcaptcha.succeed("curl --fail --connect-timeout 10 ${urlRoot}/api/v1/meta/health")
    health_data = json.loads(json_str)
    assert health_data == {'db': True, 'redis': True}
  '';
}
