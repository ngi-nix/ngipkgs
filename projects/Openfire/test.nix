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

      # open browser
      server.succeed("su - alice -c '${env} chromium http://localhost:${port} >&2 &'")
      server.wait_for_text(r"(Welcome|Setup|Openfire)")

      with subtest("Setup Openfire"):
        # Lagnuage Selection
        server.send_key("end")
        server.wait_for_text(r"(language|translation|Continue)")
        click_position(873, 540) # Continue

        # Server Settings
        server.wait_for_text(r"(network|XMPP|FQDN|Restrict|Console|Access)")
        click_position(460, 462) # Restrict Admin Console Access (disable)
        click_position(873, 670) # Continue

        # Database Settings
        server.wait_for_text(r"(Standard|Connection|Embedded|HSQLDB)")
        click_position(300, 400) # Embedded Database
        click_position(873, 490) # Continue

        # Profile Settings
        server.wait_for_text(r"(Profile|Default|user|group|LDAP)")
        click_position(873, 510) # Continue

        # Admin Account
        server.wait_for_text(r"(Administrator|Email|Address|Password)")
        server.send_chars("admin")
        server.send_key("tab")
        server.send_chars("admin\n")

        server.wait_for_console_text("Finished processing all plugins.")
        click_position(361, 382) # Login to the admin console

        # Login
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

        with subtest("Enable `adminConsole.access.allow-wildcards-in-excludes` property"):
          server.succeed("""
            su - alice -c '${env} chromium "http://localhost:9090/server-properties.jsp?sortOrder=1&sortColumnNumber=0&searchName=allow-wildcards-in-excludes" >&2 &'
          """)

          # Login
          server.wait_for_text(r"(openfire|Administration|console|username|password)")
          server.send_chars("admin")
          server.send_key("tab")
          server.send_chars("admin\n")
          server.wait_for_text(r"(allow|wildcards|excludes|System|Properties|Name|Value)")

          # scroll to the right
          for i in range(10):
            server.send_key("right")

          click_position(978, 538) # Edit property
          server.send_key("ctrl-a")
          server.send_chars("true")
          click_position(319, 622) # Save property
          server.wait_for_text(r"(properties|updated|hidden|system)")

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

      # server.succeed("su - alice -c '${env} xterm >&2 &'")
      # server.send_chars("xdotool getmouselocation --shell\n")
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
