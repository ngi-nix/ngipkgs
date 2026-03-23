{ sources, ... }:
{
  name = "liberaforms";

  nodes = {
    server =
      {
        config,
        lib,
        ...
      }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.liberaforms
          sources.examples.Liberaforms.basic
        ];
      };
  };

  testScript =
    { nodes, ... }:
    ''
      start_all()

      with subtest("liberaforms"):
          server.wait_for_unit("liberaforms.service")

          res = server.wait_until_succeeds("curl --fail http://localhost", timeout=80)
          assert("ethical form software" in res)

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

  # Debug interactively with:
  # - nix build -f . projects.Liberaforms.tests.liberaforms.driverInteractive
  # - ./result/bin/nixos-test-driver
  # - run_tests()
  # ssh -o User=root vsock%3 (can also do vsock/3, but % works with scp etc.)
  interactive.sshBackdoor.enable = true;

  interactive.nodes.server =
    { config, ... }:
    let
      port = 5000;
    in
    {
      virtualisation.forwardPorts = [
        {
          from = "host";
          host.port = port;
          guest.port = port;
        }
        {
          from = "host";
          host.port = 3939;
          guest.port = 80;
        }
      ];

      # forwarded ports need to be accessible
      networking.firewall.allowedTCPPorts = [ port ];
    };
}
