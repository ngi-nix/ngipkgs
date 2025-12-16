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

        test-support.displayManager.auto.user = "alice";

        programs.chromium.enable = true;

        environment.systemPackages = with pkgs; [
          chromium
          xdotool # automate clicks
        ];

        # more memory for chrome
        virtualisation.memorySize = 4096;

        services.openfire-server = {
          settings.jive.adminConsole.interface = "0.0.0.0";
          settings.jive.autosetup.run = true;
          settings.jive.autosetup.users = {
            alice = {
              username = "alice";
              password = "alice";
              name = "Alice";
              email = "alice@example.org";
            };
          };
        };
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    let
      cfg = nodes.server.services.openfire-server;
      port = toString cfg.servicePort;
      user = nodes.server.users.users.alice;
      env = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${toString user.uid}/bus DISPLAY=:0";
    in
    # py
    ''
      def click_position(x: int, y: int):
        server.succeed(f"su - alice -c 'xdotool mousemove --sync {x} {y} click 1'")
        server.sleep(1)

      def create_user(name: str, password: str):
        server.succeed(f"""
          curl -f \
            http://localhost:9090/plugins/restapi/v1/users \
            -u "admin:admin" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            --data \
              '{{ \
                "username": "{name}", \
                "password": "{password}" \
              }}'
        """)

      start_all()

      server.wait_for_unit("openfire-server.service")
      server.wait_for_open_port(${port})

      server.succeed("curl -f http://localhost:${port}")

      server.wait_for_x()

      with subtest("Setup Openfire"):
        server.wait_for_console_text("Finished processing all plugins.")

        # Login as admin
        server.succeed("su - alice -c '${env} chromium http://localhost:${port} >&2 &'")
        server.wait_for_text(r"(openfire|Administration|console|username|password)")
        server.send_chars("admin")
        server.sleep(1)
        server.send_key("tab")
        server.sleep(1)
        server.send_chars("admin\n")
        server.wait_for_text(r"(Information|Realtime|News|Uptime|Version)")

      with subtest("Enable Rest API"):
        click_position(194, 214) # Server Settings

        server.wait_for_text(r"(Profile|Client|Resource|Private|REST|API)")
        click_position(74, 671) # REST API

        server.wait_for_text(r"(REST|API|secret|key|auth|authentication)")
        click_position(318, 473) # Enabled
        server.send_key("end")
        server.wait_for_text(r"(Save|Additional|Logging)")
        click_position(305, 646) # Save Settings

        # Reload rest-api plugin
        server.succeed("touch ${cfg.stateDir}/plugins/${cfg.package.passthru.openfirePlugins.rest-api.jarName}.jar")
        server.wait_for_console_text("Finished processing all plugins.")

      create_user("alice", "alice")
      create_user("bob", "bob")

      server.succeed("""
        curl -f \
          http://localhost:9090/plugins/restapi/v1/chatrooms \
          -u "admin:admin" \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          --data \
            '{ \
              "roomName": "global", \
              "naturalName": "global-2", \
              "description": "Global chat room"
            }'
      """)
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
              # # galene
              # 7443
            ];
      };
  };
}
