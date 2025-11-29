{
  lib,
  pkgs,
  sources,
  ...
}:
{
  name = "PdfDing minio backups";

  nodes = {
    machine =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.pdfding
          sources.examples.PdfDing.minio
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
          minio-client
          sqlite
        ];

        services.pdfding.installWrapper = true;
        services.pdfding.installTestHelpers = true;
      };
  };

  # Tests the most basic user functionality expected from pdfding backup service
  testScript =
    { nodes, ... }:
    let
      inherit (nodes.machine.services.pdfding) port;
      stateDir = "/var/lib/pdfding";
    in
    # py
    ''
      # start vms
      start_all()

      # create admin
      machine.wait_for_unit("multi-user.target")
      machine.succeed("DJANGO_SUPERUSER_PASSWORD=admin pdfding-manage createsuperuser --no-input --username admin --email admin@localhost")

      # login
      endpoint = "http://localhost:${toString port}"
      cookie_jar = "/tmp/cookies.txt"
      machine.succeed(f"""
        curl -f \
          -X POST -c {cookie_jar} -b {cookie_jar} \
          -d "csrfmiddlewaretoken=$(curl -f -c {cookie_jar} -s '{endpoint}/accountlogin/' | grep -oP 'name="csrfmiddlewaretoken" value="\\K[^"]+')" \
          -d "login=admin@localhost" \
          -d "password=admin" \
          {endpoint}/accountlogin/
      """)

      test_pdf = "${pkgs.pdfding.src}/pdfding/pdf/tests/data/dummy.pdf"

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

      machine.succeed("""
        source /run/secrets/rendered/minio-creds
        mc alias set local http://127.0.0.1:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
      """)

      print(machine.succeed("realpath /run/current-system/sw/bin/backup-immediate"))
      print(machine.succeed("backup-immediate"))
      machine.sleep(5)

      # verify minio has that pdf file
      machine.succeed("mc stat local/pdfding/1/pdf/dummy.pdf")
    '';

  # Debug interactively with:
  # - nix run .#checks.x86_64-linux.projects/PdfDing/nixos/tests/basic.driverInteractive -L
  # - start_all() / run_tests()
  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock%3
  interactive.nodes.machine =
    { config, ... }:
    let
      ports = [
        config.services.pdfding.port
        9000
        9001
      ];
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
      }) ports;

      # forwarded ports need to be accessible
      networking.firewall.allowedTCPPorts = ports;
    };
}
