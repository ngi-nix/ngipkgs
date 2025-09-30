{
  sources,
  ...
}:

{
  name = "Tau Client";

  interactive.sshBackdoor.enable = true;

  nodes = {
    machine =
      { lib, pkgs, ... }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.tau-radio
          sources.modules.services.tau-tower
          sources.examples.Tau."Enable tau-radio"
          sources.examples.Tau."Enable tau-tower"
        ];

        environment.systemPackages = with pkgs; [
          sox
        ];

        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = true;

          # not recommended in a normal setup, but is required for pipewire to work in the test
          systemWide = true;

          wireplumber.enable = true;
        };

        virtualisation.qemu.options = [
          # enable dummy audio
          "-audiodev none,id=my_audiodev"
          "-device virtio-sound-pci,audiodev=my_audiodev"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    # python
    ''
      start_all()

      machine.wait_for_unit("tau-tower.service")
      machine.wait_for_console_text("Broadcasting on")

      machine.succeed("install -D /etc/tau/config.toml -t $HOME/.config/tau")
      machine.succeed("sed -i 's/@password@/superSecretPassword/' $HOME/.config/tau/config.toml")

      # wait for pipewire setup to finish
      machine.wait_for_unit("multi-user.target")

      # create a virtual microphone for playing back audio
      machine.succeed("pw-loopback -n sine-loopback --capture-props='media.class=Audio/Source' >/dev/null &")

      # generate sine wave file
      machine.succeed("sox -n $HOME/sine.wav synth 5 sine 10 rate 48000")

      # capture virtual microphone audio
      # NOTE: file name is automatically appended with `.ogg`
      machine.succeed("tau-radio -f $HOME/test >/dev/null &")
      machine.sleep(2)

      # play sine wave, which is picked up by the virtual mic, and thus
      # captured by tau-radio
      machine.succeed("pw-play --target sine-loopback $HOME/sine.wav")
      machine.sleep(2)

      # close tau-radio
      machine.succeed("pgrep -io 'tau-radio' | xargs kill -SIGINT ")
      machine.sleep(2)

      # check if audio is captured successfully
      machine.succeed("test -s $HOME/test.ogg")
    '';
}
