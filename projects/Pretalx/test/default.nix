{
  sources,
  lib,
  ...
}: let
  inherit
    (lib)
    mkForce
    ;
in {
  name = "pretalx tests";

  nodes = {
    server = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        sources.examples."Pretalx/base"
        sources.examples."Pretalx/postgresql"
        sources.modules.default
        sources.modules."services.ngi-pretalx"
        sources.modules.sops-nix
        sources.modules.unbootable
      ];

      unbootable = mkForce false;

      sops = mkForce {
        age.keyFile = "/run/keys.txt";
        defaultSopsFile = ./sops/pretalx.yaml;
      };

      # must run before sops sets up keys
      boot.initrd.postDeviceCommands = ''
        cp -r ${./sops/keys.txt} /run/keys.txt
        chmod -R 700 /run/keys.txt
      '';

      services.ngi-pretalx.site.url = mkForce "http://localhost:8000";

      # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
      # to provide a slightly nicer console, and while we're at it,
      # also use a nice font.
      # With kmscon, we can for example zoom in/out using [Ctrl] + [+]
      # and [Ctrl] + [-]
      services.kmscon = {
        enable = true;
        fonts = [
          {
            name = "Fira Code";
            package = pkgs.fira-code;
          }
        ];
      };
    };
  };

  testScript = {nodes, ...}: ''
    start_all()

    with subtest("pretalx-web"):
        # NOTE: We cannot use just `server.wait_for_unit("pretalx-web.service")`
        # because the systemd service will change state to "active", before
        # pretalx is actually ready to serve requests, leading to failure.
        # pretalx/Django does not support the sd_notify protocol as of
        # 2023-08-11, which could be used to notify systemd about the state of
        # the webserver.
        server.wait_for_unit("pretalx-web.service")
        server.wait_until_succeeds("curl --fail --connect-timeout 2 localhost", timeout=60)

        server.execute("${nodes.server.services.ngi-pretalx.package.meta.mainProgram} create_test_event")

        # NOTE: "democon" is the slug of the event created by
        # `pretalx-manage create_test_event`.
        server.succeed("curl --fail --connect-timeout 10 http://localhost/democon")
  '';
}
