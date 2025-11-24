{
  lib,
  pkgs,
  sources,
  ...
}:
{
  name = "Openfire server";

  nodes = {
    server =
      { lib, config, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.services.openfire-server
          sources.examples.Openfire."Enable Openfire server"

          # enable graphical session + users (alice, bob)
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
          "${sources.inputs.nixpkgs}/nixos/tests/common/user-account.nix"
        ];

        services.xserver.enable = true;
        test-support.displayManager.auto.user = "alice";

        programs.chromium.enable = true;

        environment.systemPackages = with pkgs; [
          chromium
          xdotool # automate clicks
        ];

        # more memory for chrome
        virtualisation.memorySize = 4096;
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    let
      port = toString nodes.server.services.openfire-server.servicePort;
      user = nodes.server.users.users.alice;
      env = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${toString user.uid}/bus DISPLAY=:0";
    in
    # py
    ''
      def click_position(x: int, y: int):
        server.succeed(f"su - alice -c '${env} xdotool mousemove --sync {x} {y} click 1'")
        server.sleep(1)

      start_all()

      server.wait_for_unit("openfire-server.service")
      server.wait_for_open_port(${port})

      server.succeed("curl -f http://localhost:${port}")

      server.wait_for_x()

      # open browser
      server.succeed("su - alice -c '${env} chromium http://127.0.0.1:9090 >&2 &'")
    '';

  # ssh -o User=root vsock/3
  interactive.sshBackdoor.enable = true;

  # nix run .#checks.x86_64-linux.projects/Openfire/nixos/tests/basic.driverInteractive -L
  # NOTE: diable `Restrict Admin Console Access` in the `Server Settings`, else you won't be able to login.
  interactive.nodes = {
    server =
      { config, ... }:
      {
        virtualisation.forwardPorts =
          let
            cfg = config.services.openfire-server;
          in
          map
            (port: {
              from = "host";
              host = { inherit port; };
              guest = { inherit port; };
            })
            [
              cfg.securePort
              cfg.servicePort
              # client to server
              5222
              5223
              # web binding
              7979
              7443
            ];
      };
  };
}
