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

        environment.systemPackages = [ pkgs.pdfding ];
        services.pdfding.port = port;

        virtualisation.forwardPorts = map (port: {
          from = "host";
          host.port = port;
          guest.port = port;
        }) [ port ];

        # forwarded ports need to be accessible
        networking.firewall.allowedTCPPorts = [ port ];
      };
  };

  # Debug interactively with:
  # - nix run .#checks.x86_64-linux.projects/PdfDing/nixos/tests/basic.driverInteractive -L
  # - start_all() / run_tests()
  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock/3
  interactive.nodes.machine =
    { config, ... }:
    {
    };

  extraPythonPackages = p: [
    p.requests
    p.types-requests
  ];

  # TODO
  # Tests the most basic user functionality expected from pdfding
  testScript =
    { nodes, ... }:
    let
      endpoint = "http://localhost:${toString port}";
    in
    # py
    ''
      import requests

      # start
      start_all()

      # create admin
      machine.wait_for_unit("multi-user.target")
      machine.succeed("DJANGO_SUPERUSER_PASSWORD=test pdfding-manage createsuperuser --no-input --username admin --email root@localhost")

      # create normal user via API?
      s = requests.Session()

      # get the csrf token
      r = s.get("${endpoint}/accountlogin/?next/pdf/")
      csrf_token = r.text.split('name="csrfmiddlewaretoken" value="')[1].split('"')[0]

      data = {
        "csrfmiddlewaretoken": csrf_token,
        "login": "root@localhost",
        "password": "test",
        "next": "/pdf/",
      }
      r = s.post("${endpoint}/accountlogin/", data=data)
      assert r.status_code == 200, "Failed to authenticate"

      # make sample pdf (could be any test file or valid pdf?)
      # upload via API to user
      # download via API to user
      # https://github.com/mrmn2/PdfDing/blob/master/docs/guides.md#consumption-directory
      # make user consume pdfs via admin
      # test if user can access via API

      machine.succeed("ls")
    '';
}
