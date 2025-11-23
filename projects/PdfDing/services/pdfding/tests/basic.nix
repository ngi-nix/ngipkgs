{
  lib,
  pkgs,
  sources,
  ...
}:
let
  port = 8000;
in
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
          pdfding
          sqlite
        ];

        services.pdfding.port = port;
      };
  };

  # Debug interactively with:
  # - nix run .#checks.x86_64-linux.projects/PdfDing/nixos/tests/basic.driverInteractive -L
  # - start_all() / run_tests()
  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock%3
  interactive.nodes.machine =
    { config, ... }:
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

  # Tests the most basic user functionality expected from pdfding
  # heavy e2e test suite is ran on e2e.nix
  testScript =
    { nodes, ... }:
    # py
    ''
      # start
      start_all()

      # create admin
      machine.wait_for_unit("multi-user.target")
      machine.succeed("DJANGO_SUPERUSER_PASSWORD=test pdfding-manage createsuperuser --no-input --username admin --email root@localhost")

      # login
      cookie_jar = "/tmp/cookies.txt"
      endpoint = "http://localhost:${toString port}"
      machine.succeed(f"""
        curl -f \
          -X POST -c {cookie_jar} -b {cookie_jar} \
          -d "csrfmiddlewaretoken=$(curl -f -c {cookie_jar} -s '{endpoint}/accountlogin/' | grep -oP 'name="csrfmiddlewaretoken" value="\\K[^"]+')" \
          -d "login=root@localhost" \
          -d "password=test" \
          {endpoint}/accountlogin/
      """)

      test_pdf = "${pkgs.pdfding.src}/pdfding/pdf/tests/data/dummy.pdf"

      # verify no pdfs exist in db
      machine.succeed("sqlite3 /var/lib/pdfding/db/db.sqlite3 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^0$'")

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
      machine.succeed("test -f /var/lib/pdfding/media/1/pdf/*.pdf")

      # verify one entry exists in sqlite db
      machine.succeed("sqlite3 /var/lib/pdfding/db/db.sqlite3 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^1$'")
    '';
}
