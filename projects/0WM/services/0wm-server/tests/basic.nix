{
  sources,
  ...
}:

{
  name = "0WM server";

  interactive.sshBackdoor.enable = true;

  nodes = {
    machine =
      {
        lib,
        pkgs,
        config,
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
          # "${sources.inputs.nixpkgs}/nixos/tests/common/wayland-cage.nix"
          "${sources.inputs.nixpkgs}/nixos/tests/common/user-account.nix"
        ];

        services.xserver.enable = true;
        test-support.displayManager.auto.user = "alice";
        services.getty.autologinUser = "alice";

        # services.zwm-server.settings.port = lib.mkForce 8000;
        services.zwm-server.settings.interface = lib.mkForce "ap.local";

        programs.chromium.enable = true;
        programs.chromium.extensions = [
          "cgffilbpcibhmcfbgggfhfolhkfbhmik" # Immersive Web Emulator (XR)
          "lfhmikememgdcahcdlaciloancbhjino" # CORS Unblock
        ];

        environment.systemPackages = with pkgs; [
          _0wm-ap-mock
          _0wm-opmode
          chromium
        ];

        networking.firewall.allowedTCPPorts = [
          8001
          8002
          8003
        ];

        networking.hosts."0.0.0.0" = [ "ap.local" ];

        virtualisation.memorySize = 4096;
        virtualisation.forwardPorts =
          let
            cfg = config.services.zwm-server;
          in
          [
            {
              from = "host";
              host.port = cfg.settings.port;
              guest.port = cfg.settings.port;
            }
            {
              from = "host";
              host.port = 8001;
              guest.port = 8001;
            }
            {
              from = "host";
              host.port = 8002;
              guest.port = 8002;
            }
            {
              from = "host";
              host.port = 8003;
              guest.port = 8003;
            }
          ];

        virtualisation.qemu.options = [
          "-cpu host"
          "-device virtio-gpu-gl"
          "-display default,gl=on,show-cursor=on"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    # py
    ''
      start_all()

      machine.wait_for_unit("zwm-server.service")

      machine.succeed("mkdir -p /logs")

      machine.succeed("0wm-client &> /logs/client.log &")
      machine.succeed("0wm-opmode &> /logs/opmode.log &")
      machine.succeed("0wm-ap-mock &> /logs/ap-mock.log &")

      machine.wait_for_x()

      # TODO: this does not work. open from in the graphical session
      machine.succeed("su -m alice -c sh 'env DISPLAY=:0 chromium --enable-unsafe-swiftshader http://127.0.0.1:8002'")
    '';
}
