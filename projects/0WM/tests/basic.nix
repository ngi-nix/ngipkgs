{
  sources,
  ...
}:

{
  name = "0WM server + client";

  nodes = {
    machine =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [
          sources.modules.ngipkgs

          sources.modules.services.zwm-server
          sources.modules.programs.zwm-client
          sources.examples."0WM"."Enable 0WM server"
          sources.examples."0WM"."Enable 0WM client"

          # enable graphical session + users (alice, bob)
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
          "${sources.inputs.nixpkgs}/nixos/tests/common/user-account.nix"
        ];

        services.xserver.enable = true;
        test-support.displayManager.auto.user = "alice";

        programs.chromium.enable = true;
        programs.chromium.extensions = [
          "cgffilbpcibhmcfbgggfhfolhkfbhmik" # Immersive Web Emulator (XR)
          "lfhmikememgdcahcdlaciloancbhjino" # CORS Unblock
        ];

        environment.systemPackages = with pkgs; [
          _0wm-ap-mock
          _0wm-opmode
          chromium
          xdotool # automate clicks
        ];

        # browser requires more memory
        virtualisation.memorySize = 4096;
      };
  };

  # Debug interactively with:
  # - nix run .#checks.x86_64-linux.projects/0WM/nixos/tests/basic.driverInteractive -L
  # - run_tests()
  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock/3
  interactive.nodes = {
    machine =
      {
        lib,
        config,
        ...
      }:
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
              8001 # opmode
              8002 # client
              8003 # ap mock
              config.services.zwm-server.settings.port
            ];

        # forwarded ports need to be accessible
        networking.firewall.enable = false;

        # make ports reachable on host and VM
        environment.variables = lib.genAttrs [
          "CLIENT_ADDRESS"
          "OP_MODE_ADDRESS"
          "AP_MOCK_ADDRESS"
        ] (_: "0.0.0.0");
      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    # python
    ''
      def click_position(x: int, y: int):
        machine.succeed(f"env DISPLAY=:0 sudo -u alice xdotool mousemove --sync {x} {y} click 1")
        machine.sleep(1)

      def click_start():
        machine.wait_for_text("Click here to start")
        click_position(512, 417)

      start_all()

      machine.wait_for_unit("zwm-server.service")

      machine.succeed("mkdir -p /logs")

      machine.succeed("0wm-client &> /logs/client.log &")
      machine.succeed("0wm-opmode &> /logs/opmode.log &")
      machine.succeed("0wm-ap-mock >&2 /logs/ap-mock.log &")

      machine.wait_for_x()

      # open browser
      machine.succeed("env DISPLAY=:0 sudo -u alice chromium http://127.0.0.1:8002 >&2 &")

      click_start()

      # allow location permissions
      machine.wait_for_text("Allow while visiting the site")
      click_position(294, 229)

      machine.send_key("f5")

      click_start()

      # start scan
      machine.sleep(5)
      click_position(982, 410)

      machine.wait_for_console_text('"GET /cgi-bin/scan/radio0 HTTP/1.1" 200')
      machine.wait_for_console_text('"GET /cgi-bin/scan/radio1 HTTP/1.1" 200')
    '';
}
