{sources, ...}: {
  name = "liberaforms";

  nodes = {
    server = {
      config,
      lib,
      ...
    }: {
      imports = [
        sources.modules.default
        sources.modules."services.liberaforms"
      ];

      services.liberaforms = {
        enable = true;
        enablePostgres = true;
        enableNginx = true;
        domain = "localhost";
      };

      time.timeZone = "Europe/Paris";
    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("liberaforms"):
        server.wait_for_unit("liberaforms.service")

        res = server.wait_until_succeeds("curl --fail http://localhost", timeout=10)
        assert("Ethical forms with LiberaForms" in res)

        res = server.succeed("curl http://localhost/site/recover-password -c cookies.txt -b cookies.txt")
        assert("Recover password" in res)

        import re
        match = re.search(r'name="csrf_token" type="hidden" value="([\w.-]+)"', res)
        if match is None:
            raise Exception("The CSRF session token is missing")
        csrf_token = match.group(1)
        res = server.succeed("curl http://localhost/site/recover-password -c cookies.txt -b cookies.txt"
            + " -X POST -H 'referer: https://localhost/site/recover-password'"
            + " --form 'csrf_token=" + csrf_token + "'"
            + " --form 'email=example@example.org'")
        assert("Redirecting..." in res)

        res = server.succeed("curl http://localhost/user/login")
        assert("Login to your account" in res)
  '';
}
