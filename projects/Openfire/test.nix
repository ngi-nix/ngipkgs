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
        server.succeed(f"su - alice -c 'xdotool mousemove --sync {x} {y} click 1'")
        server.sleep(1)

      start_all()

      server.wait_for_unit("openfire-server.service")
      server.wait_for_open_port(${port})

      server.succeed("curl -f http://localhost:${port}")

      server.wait_for_x()

      # open browser
      server.succeed("su - alice -c '${env} chromium http://127.0.0.1:9090 >&2 &'")
      server.wait_for_text(r"(Welcome|Setup|Openfire)")

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

      server.wait_for_text(r"(openfire|Administration|console|username|password)")
      server.send_chars("admin")
      server.send_key("tab")
      server.send_chars("admin\n")

      server.wait_for_text(r"(Information|Realtime|News|Uptime|Version)")
      click_position(194, 214) # Server Settings

      server.wait_for_text(r"(Profile|Client|Resource|Private|REST|API)")
      click_position(74, 671) # REST API

      server.wait_for_text(r"(REST|API|secret|key|auth|authentication)")
      click_position(318, 473) # Enabled
      server.send_key("end")
      server.wait_for_text(r"(Save|Additional|Logging)")
      click_position(305, 646) # Save Settings

      # Reload rest-api plugin
      server.succeed("touch ${nodes.server.services.openfire-server.stateDir}/plugins/rest-api.jar")
      server.wait_for_console_text("Finished processing all plugins.")
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
