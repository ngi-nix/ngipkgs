{sources, ...}: let
  port = 7000;
  urlRoot = "http://localhost:${builtins.toString port}";
in {
  name = "test of mcaptcha with database and other services all running on the same node";

  nodes.mcaptcha = {pkgs, ...}: {
    imports = [
      sources.modules.default
      sources.modules."mCaptcha/service"
    ];

    services.mcaptcha.enable = true;
    services.mcaptcha.settings.server.port = port;
    services.mcaptcha.server.cookieSecretFile = pkgs.writeText "cookie-secret" "mcaptcha-cookie-secret-dm0tdGVzdC1ydW4tbWNhcHRjaGEtdGVzdHM";
    services.mcaptcha.captcha.saltFile = pkgs.writeText "salt" "asdl;kjfhjawehfpa;osdkjasdvjaksndfpoanjdfainsdfaijdsfajlkjdsaf;ajsdfweroire";
    services.mcaptcha.database.createLocally = true;
    services.mcaptcha.redis.createLocally = true;
  };

  interactive.nodes.mcaptcha = {
    networking.firewall.enable = false;
    services.mcaptcha.settings.server.ip = "0.0.0.0";
  };

  testScript = {nodes, ...}: ''
    import json
    mcaptcha.start()

    mcaptcha.wait_for_unit("mcaptcha.service")
    mcaptcha.wait_until_succeeds("curl --fail --connect-timeout 2 ${urlRoot}", timeout=60)

    mcaptcha.succeed("curl --fail --connect-timeout 10 ${urlRoot}/widget")

    json_str = mcaptcha.succeed("curl --fail --connect-timeout 10 ${urlRoot}/api/v1/meta/health")
    health_data = json.loads(json_str)
    assert health_data == {'db': True, 'redis': True}
  '';
}
