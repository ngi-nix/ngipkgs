{
  lib,
  sources,
  ...
}:

{
  name = "PdfDing default";

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
      };
  };

  # Debug interactively with:
  # - nix run .#checks.x86_64-linux.projects/PdfDing/nixos/tests/basic.driverInteractive -L
  # - start_all() / run_tests()
  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock/3
  interactive.nodes.machine =
    { config, ... }:
    {
      # forward ports from VM to host
      virtualisation.forwardPorts =
        map
          (port: {
            from = "host";
            host.port = port;
            guest.port = port;
          })
          [
            config.services.pdfding.port
          ];

      # forwarded ports need to be accessible
      networking.firewall.allowedTCPPorts = [ config.services.pdfding.port ];
    };

  # TODO
  # Tests the most basic user functionality expected from pdfding
  testScript =
    { nodes, ... }:
    # py
    ''
      start_all()

      # start
      # create admin
      # create normal user via API?

      # make sample pdf (could be any test file or valid pdf?)
      # upload via API to user
      # download via API to user
      # https://github.com/mrmn2/PdfDing/blob/master/docs/guides.md#consumption-directory
      # make user consume pdfs via admin
      # test if user can access via API

      machine.succeed()
    '';
}
