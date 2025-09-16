{
  sources,
  lib,
  pkgs,
  ...
}@args:

# We need all the same setup as the libervia-backend test, so just extend that one with desktop things
let
  backendTest = import ./backend.nix args;
in
backendTest
// {
  name = "Libervia-desktop-kivy";

  nodes.server =
    {
      config,
      lib,
      pkgs,
      ...
    }@args2:
    let
      backendTestConfig = backendTest.nodes.server args2;
    in
    backendTestConfig
    // {
      imports = backendTestConfig.imports ++ [
        sources.examples.Libervia.desktop
      ];

      environment = backendTestConfig.environment // {
        systemPackages =
          (backendTestConfig.environment.systemPackages or [ ])
          ++ (with pkgs; [
            xdotool # Control the mouse
          ]);
      };
    };

  testScript =
    { nodes, ... }@args3:
    (backendTest.testScript args3)
    + ''
      next_workspace()

      with subtest("libervia-desktop-kivy works"):
          # Start it
          spawn_terminal()
          machine.send_chars("libervia-desktop-kivy 2>&1 | tee -a ~/desktop.log\n")
          machine.wait_for_text("Select a profile")
          machine.send_key("alt-f10")

          # Log in as alice
          machine.succeed("sudo -su alice xdotool mousemove 518 163 click 1")
          machine.sleep(2)
          machine.succeed("sudo -su alice xdotool mousemove 509 721 click 1")
          machine.wait_for_text("chat")

          # Enter chat
          machine.succeed("sudo -su alice xdotool mousemove 493 199 click 1")
          machine.wait_for_text("Your contacts")

          # Open conversation with ourselves
          machine.succeed("sudo -su alice xdotool mousemove 80 148 click 1")
          machine.wait_for_text("${backendTest.passthru.xmppMessage}")
    '';
}
