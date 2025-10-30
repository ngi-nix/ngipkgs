{
  sources,
  pkgs,
  ...
}:

{
  name = "Repath Studio";

  nodes = {
    machine =
      { pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.repath-studio
          sources.examples.Repath-Studio."Enable repath-studio"

          # enable graphical session + users (alice, bob)
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
          "${sources.inputs.nixpkgs}/nixos/tests/common/user-account.nix"
        ];

        services.xserver.enable = true;
        test-support.displayManager.auto.user = "alice";

        environment.systemPackages = with pkgs; [
          xdotool
        ];

        # electron application, give more memory
        virtualisation.memorySize = 4096;
      };
  };

  enableOCR = true;

  interactive.sshBackdoor.enable = true; # ssh -o User=root vsock/3

  testScript =
    { nodes, ... }:
    # python
    ''
      start_all()

      # `env DISPLAY=:0 sudo -u alice watch -t -n 0.1 xdotool getmouselocation` for finding coordinates
      def click_position(x: int, y: int):
          machine.succeed(f"env DISPLAY=:0 sudo -u alice xdotool mousemove --sync {x} {y} click 1")
          machine.sleep(1)

      machine.wait_for_x()
      machine.succeed("env DISPLAY=:0 sudo -u alice repath-studio &> /tmp/repath.log &")
      machine.wait_for_text("Welcome") # initial telemetry prompt

      machine.screenshot("Repath-Studio-GUI-Welcome")
      click_position(440, 440) # "No, thank you" button

      machine.send_key("ctrl-shift-s")
      machine.sleep(2)
      machine.send_chars("/tmp/saved.rps\n")
      machine.sleep(2)
      print(machine.succeed("cat /tmp/saved.rps"))
      assert "${pkgs.repath-studio.version}" in machine.succeed("cat /tmp/saved.rps")

      machine.screenshot("Repath-Studio-GUI")
    '';
}
