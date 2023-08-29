{configurations, ...}: {
  name = "pretalx tests";

  nodes = {
    server = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        configurations.server
      ];

      sops = pkgs.lib.mkForce {
        age.keyFile = ./sops/keys.txt;
        defaultSopsFile = ./sops/pretalx.yaml;
      };

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

        server.execute("pretalx create_test_event")

        # NOTE: "democon" is the slug of the event created by
        # `pretalx create_test_event`.
        server.succeed("curl --fail --connect-timeout 10 http://localhost/democon")
  '';
}
