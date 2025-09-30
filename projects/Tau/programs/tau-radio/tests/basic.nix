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

          # add users alice and bob (passwords: foobar)
          (sources.inputs.nixpkgs + "/nixos/tests/common/user-account.nix")
        ];

        environment.systemPackages = with pkgs; [
          alsa-utils
        ];

        # services.getty.autologinUser = "alice";
        security.sudo.wheelNeedsPassword = false;
        users.users.alice.extraGroups = [
          "audio"
          "pipewire"
          "wheel"
        ];

        # required for pipewire
        services.xserver = {
          enable = true;
          windowManager.icewm.enable = true;
        };

        services.displayManager = {
          defaultSession = lib.mkDefault "none+icewm";
          autoLogin.user = "nixos";
        };

        virtualisation.graphics = true;

        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;

          # not recommended in a normal setup, but is required for pipewire to work in the test
          systemWide = true;

          wireplumber = {
            enable = true;
          };
        };

        virtualisation.qemu.options = [
          # Enable audio
          "-device intel-hda"
          "-device hda-duplex"
        ];
      };
  };

  testScript =
    { nodes, ... }:
    # py
    ''
      start_all()

      machine.wait_for_unit("tau-tower.service")
      machine.wait_for_console_text("Broadcasting on")

      machine.succeed("mkdir -p $HOME/.config/tau")
      machine.succeed("cp /etc/tau/config.toml $HOME/.config/tau/config.toml")

      machine.wait_for_unit("multi-user.target")

      machine.systemctl("--machine=alice@.host --user unmask pipewire")
      machine.systemctl("--machine=alice@.host --user unmask pipewire.socket")
      machine.systemctl("--machine=alice@.host --user unmask wireplumber")

      machine.execute("tau-radio \
      --no-recording \
      --port ${toString nodes.machine.services.tau-tower.settings.mount_port} \
      &> $HOME/tau.log")
      machine.sleep(5)
      machine.send_key("ctrl-c")
      machine.succeed("grep 'HTTP error: 200 OK' $HOME/tau.log")
    '';
}
