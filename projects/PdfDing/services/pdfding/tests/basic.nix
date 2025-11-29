{
  lib,
  pkgs,
  sources,
  ...
}:
{
  name = "PdfDing sqlite";

  nodes = {
    machine =
      { ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.pdfding
          sources.examples.PdfDing.basic
          "${sources.inputs.sops-nix}/modules/sops"
        ];

        # NOTE: when upstreaming module and tests to nixpkgs
        # need to remove sops and use plain text test credentials
        sops = lib.mkForce {
          age.keyFile = "/run/keys.txt";
          defaultSopsFile = ./sops/pdfding.yaml;
        };

        # must run before sops sets up keys
        boot.initrd.postDeviceCommands = ''
          cp -r ${./sops/keys.txt} /run/keys.txt
          chmod -R 700 /run/keys.txt
        '';

        environment.systemPackages = with pkgs; [
          sqlite
        ];

        services.pdfding.installWrapper = true;

        # test email validation works
        services.pdfding.extraEnvironment = {
          EMAIL_BACKEND = "SMTP";
          SMTP_HOST = "localhost";
          SMTP_PORT = "1025";
          SMTP_USER = ""; # mailpit doesn't need auth
          SMTP_PASSWORD = "";
          SMTP_USE_TLS = "FALSE";
          SMTP_USE_SSL = "FALSE";
        };

        # enable mailpit
        services.mailpit.instances.default = { };
      };
  };

  # Tests the most basic user functionality expected from pdfding
  # heavy e2e test suite is ran on e2e.nix
  testScript =
    { nodes, ... }:
    let
      inherit (nodes.machine.services.pdfding) port;
      mailpitApiEndpoint = "http://${nodes.machine.services.mailpit.instances.default.listen}/api/v1";
      stateDir = "/var/lib/pdfding";
    in
    # py
    ''
      import json
      from pprint import pprint

      # start vms
      start_all()

      # create admin
      machine.wait_for_unit("multi-user.target")
      machine.succeed("DJANGO_SUPERUSER_PASSWORD=admin pdfding-manage createsuperuser --no-input --username admin --email admin@localhost")

      cookie_jar = "/tmp/cookies.txt"
      endpoint = "http://localhost:${toString port}"

      with subtest("login and basic usage"):
        # login
        machine.succeed(f"""
          curl -f \
            -X POST -c {cookie_jar} -b {cookie_jar} \
            -d "csrfmiddlewaretoken=$(curl -f -c {cookie_jar} -s '{endpoint}/accountlogin/' | grep -oP 'name="csrfmiddlewaretoken" value="\\K[^"]+')" \
            -d "login=admin@localhost" \
            -d "password=admin" \
            {endpoint}/accountlogin/
        """)

        test_pdf = "${pkgs.pdfding.src}/pdfding/pdf/tests/data/dummy.pdf"

        # verify no pdfs exist in db
        machine.succeed("sqlite3 ${stateDir}/db/db.sqlite3 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^0$'")

        # upload
        machine.succeed(f"""
          csrf_token=$(curl -f -b {cookie_jar} -c {cookie_jar} -s "{endpoint}/pdf/add" | grep -oP 'name="csrfmiddlewaretoken" value="\\K[^"]+')
          curl -f \
            -c {cookie_jar} -b {cookie_jar} \
            -F "notes=" \
            -F "tag_string=" \
            -F "description=" \
            -F "use_file_name=on" \
            -F "name=test-upload" \
            -F "file=@{test_pdf};type=application/pdf" \
            -F "csrfmiddlewaretoken=$csrf_token" \
            -H "Referer: {endpoint}/pdf/add" \
            {endpoint}/pdf/add
        """)

        # download
        machine.succeed(f"""
          pdf_id=$(curl -f -b {cookie_jar} -s "{endpoint}/pdf/" | grep -oP 'href="/pdf/view/\\K[^"]+' | head -1)
          curl -f -b {cookie_jar} -o /tmp/downloaded.pdf "{endpoint}/pdf/download/$pdf_id"
        """)

        # verify pdf in user's dir
        machine.succeed("test -f ${stateDir}/media/1/pdf/*.pdf")

        # verify one entry exists in sqlite db
        machine.succeed("sqlite3 ${stateDir}/db/db.sqlite3 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^1$'")

      with subtest("email validation"):
        # check we can reach mailpit
        machine.succeed("curl -f ${mailpitApiEndpoint}/info")

        # check that no emails exist
        result = json.loads(machine.succeed("curl -sf ${mailpitApiEndpoint}/messages"))
        pprint(result)
        assert result["total"] == 0

        # signup
        machine.succeed(f"""
          curl -f \
            -X POST -c {cookie_jar} -b {cookie_jar} \
            -d "csrfmiddlewaretoken=$(curl -f -c {cookie_jar} -s '{endpoint}/accountsignup/' | grep -oP 'name="csrfmiddlewaretoken" value="\\K[^"]+')" \
            -d "email=pdfding_new_user@example.com" \
            -d "password1=foobarbaz" \
            -d "password2=foobarbaz" \
            {endpoint}/accountsignup/
        """)

        # wait a bit for email to be processed
        machine.sleep(3)

        # verify the email was received by mailpit
        result = json.loads(machine.succeed("curl -s ${mailpitApiEndpoint}/messages"))
        pprint(result)
        assert result["total"] == 1
        assert result["messages"][0]["To"][0]["Address"] == "pdfding_new_user@example.com"
    '';

  # Debug interactively with:
  # - nix run .#checks.x86_64-linux.projects/PdfDing/nixos/tests/basic.driverInteractive -L
  # - start_all() / run_tests()
  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock%3
  interactive.nodes.machine =
    { config, ... }:
    let
      port = config.services.pdfding.port;
    in
    {
      # not needed, only for manual interactive debugging
      virtualisation.memorySize = 4096;
      environment.systemPackages = with pkgs; [
        btop
        sysz
      ];

      virtualisation.forwardPorts = map (port: {
        from = "host";
        host.port = port;
        guest.port = port;
      }) [ port ];

      # forwarded ports need to be accessible
      networking.firewall.allowedTCPPorts = [ port ];
    };
}
