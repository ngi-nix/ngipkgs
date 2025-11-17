{
  sources,
  lib,
  pkgs,
  ...
}:
let
  iconColour = "#BAFFE0";
in
{
  name = "Blink-basic";

  nodes = {
    machine =
      {
        config,
        lib,
        ...
      }:
      {
        imports = [
          (sources.inputs.nixpkgs + "/nixos/tests/common/user-account.nix")
          (sources.inputs.nixpkgs + "/nixos/tests/common/x11.nix")
          sources.modules.ngipkgs
          sources.modules.programs.blink
          sources.examples.Blink."Enable Blink"
        ];

        # Refuses to run as root
        test-support.displayManager.auto.user = "alice";

        # Running blink-qt doesn't open a window in this environment for some reason.
        # To know when it's ready, override tray icon to unique color and wait until it's found.
        programs.blink.package = pkgs.blink-qt.overridePythonAttrs (oa: {
          nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [
            pkgs.imagemagick
          ];

          postInstall = (oa.postInstall or "") + ''
            cp $out/share/blink/icons/blink.png blink.png
            magick blink.png \
              -background "${iconColour}" \
              -alpha remove -alpha off \
              $out/share/blink/icons/blink.png
          '';
        });

        environment.systemPackages = with pkgs; [
          xdotool
        ];
      };
  };

  # Need to see when app has launched
  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      # Taken from terminal-emulators.nix' check_for_pink

      from collections.abc import Callable
      import tempfile
      import subprocess

      iconColor: str = "${iconColour}"

      def check_for_color(color: str) -> Callable[[bool], bool]:
          def check_for_color_retry(final=False) -> bool:
              with tempfile.NamedTemporaryFile() as tmpin:
                  machine.send_monitor_command("screendump {}".format(tmpin.name))

                  cmd = 'convert {} -define histogram:unique-colors=true -format "%c" histogram:info:'.format(
                      tmpin.name
                  )
                  ret = subprocess.run(cmd, shell=True, capture_output=True)
                  if ret.returncode != 0:
                      raise Exception(
                          "image analysis failed with exit code {}".format(ret.returncode)
                      )

                  text = ret.stdout.decode("utf-8")
                  return color in text

          return check_for_color_retry



      start_all()
      machine.wait_for_x()

      # Ensure icon color isn't present already
      assert(
          check_for_color(iconColor)(True) == False
      ), "iconColor {} was present on the screen before we selected anything!".format(iconColor)

      machine.succeed("env DISPLAY=:0 sudo -u alice blink >&2 &")

      # Waiting for blink icon to be displayed
      with machine.nested("Waiting for the screen to have iconColor {} on it:".format(iconColor)):
          retry(check_for_color(iconColor))

      machine.screenshot("blink-indicator")

      machine.succeed("sudo -u alice xdotool mousemove 800 750 click 1")

      machine.sleep(3)
      machine.wait_for_text(r"(Blink|Call|Calls)")

      machine.screenshot("blink-app")
    '';
}
