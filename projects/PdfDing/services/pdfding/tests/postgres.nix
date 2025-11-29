{
  lib,
  pkgs,
  sources,
  ...
}:
{
  name = "PdfDing postgres";

  nodes = {
    machine =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.pdfding
          sources.examples.PdfDing.postgres
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

        environment.systemPackages = [
          config.services.postgresql.finalPackage
        ];

        services.pdfding.installWrapper = true;
        services.pdfding.installTestHelpers = true;
      };
  };

  # Tests the most basic user functionality expected from pdfding with postgres and consume feature
  testScript =
    { nodes, ... }:
    let
      stateDir = "/var/lib/pdfding";
    in
    # py
    ''
      # start
      start_all()

      # create admin
      machine.wait_for_unit("multi-user.target")

      machine.succeed("DJANGO_SUPERUSER_PASSWORD=admin pdfding-manage createsuperuser --no-input --username admin --email admin@localhost")

      test_pdf = "${pkgs.pdfding.src}/pdfding/pdf/tests/data/dummy.pdf"

      # copy to consume dir
      machine.succeed(f"sudo -u pdfding bash -c 'mkdir -p ${stateDir}/consume/1 && cp {test_pdf} ${stateDir}/consume/1/'")

      # check the file was copied
      output = machine.succeed("sudo -u pdfding bash -c 'ls -l ${stateDir}/consume/1/'")
      assert "dummy.pdf" in output, "dummy pdf file not found"

      # check there are no pdfs
      machine.succeed("sudo -u pdfding psql -tAc 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^0$'")

      print(machine.succeed("realpath /run/current-system/sw/bin/consume-immediate"))
      print(machine.succeed("consume-immediate"))
      machine.sleep(4)

      # verify pdf is in user's dir, and removed from consume dir
      machine.succeed("test -f ${stateDir}/media/1/pdf/dummy.pdf")
      machine.fail("test -f ${stateDir}/consume/1/pdf/dummy.pdf")

      # verify pdf is also in postgres db
      machine.succeed("sudo -u pdfding psql -tAc 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^1$'")
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
