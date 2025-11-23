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
  name = "PdfDing postgres";

  nodes = {
    machine =
      { config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.pdfding
          sources.examples.PdfDing.basic
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
          pkgs.pdfding
          config.services.postgresql.finalPackage

          # requires setting all credentials
          # TODO do we set this in the module itself, some wrapper or finalPackage?
          (pkgs.writeShellScriptBin "create-adminuser" ''
            set -a
            ${lib.concatMapStringsSep "\n" (f: "source ${f}") config.services.pdfding.envFiles}
            set +a
            export POSTGRES_PASSWORD=$(<${config.services.pdfding.database.passwordFile})
            pdfding-manage createsuperuser --no-input --username admin --email root@localhost
          '')
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

  # Tests the most basic user functionality expected from pdfding with postgres and consume feature
  testScript =
    { nodes, ... }:
    # py
    ''
      # start
      start_all()

      # create admin
      machine.wait_for_unit("multi-user.target")

      #print(machine.succeed("realpath $(which create-adminuser)"))
      machine.succeed("create-adminuser")

      test_pdf = "${pkgs.pdfding.src}/pdfding/pdf/tests/data/dummy.pdf"

      # copy to consume dir
      machine.succeed(f"sudo -u pdfding bash -c 'mkdir -p /var/lib/pdfding/consume/1 && cp {test_pdf} /var/lib/pdfding/consume/1/'")

      # check there are no pdfs
      machine.succeed("sudo -u pdfding psql -tAc 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^0$'")

      # wait one min (can it be made immediate?)
      machine.sleep(64)

      # verify pdf is in user's dir, and removed from consume dir
      machine.succeed("test -f /var/lib/pdfding/media/1/pdf/dummy.pdf")
      machine.fail("test -f /var/lib/pdfding/consume/1/pdf/dummy.pdf")

      # verify pdf is also in postgres db
      machine.succeed("sudo -u pdfding psql -tAc 'SELECT COUNT(*) FROM pdf_pdf' | grep -q '^1$'")
    '';
}
