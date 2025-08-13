{
  sources,
  ...
}:
{
  name = "briar";

  nodes = {
    peer1 =
      {
        pkgs,
        ...
      }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.briar
          sources.examples.Briar."Enable briar"
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
        ];

        environment.systemPackages = with pkgs; [
          xdotool
          xclip
        ];

      };
    peer2 =
      {
        pkgs,
        ...
      }:
      {
        imports = [
          sources.modules.ngipkgs
          sources.modules.programs.briar
          sources.examples.Briar."Enable briar"
          "${sources.inputs.nixpkgs}/nixos/tests/common/x11.nix"
        ];

        environment.systemPackages = with pkgs; [
          xdotool
          xclip
        ];

      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()
      peer1.wait_for_x()
      peer1.sleep(5)
      peer2.wait_for_x()
      peer2.sleep(5)

      peer1.execute("briar-desktop > /tmp/briar-desktop.log 2>&1 &")
      peer1.sleep(10)
      peer2.execute("briar-desktop > /tmp/briar-desktop.log 2>&1 &")
      peer2.sleep(10)

      def setup_peer(machine, nickname, password):
        # Create Briar Nickname
        machine.succeed("xdotool mousemove 259 371 click 1")
        machine.send_chars(f"{nickname}\n", 0.1)

        # Enter Password and create account
        machine.succeed("xdotool mousemove 259 371 click 1")
        machine.send_chars(f"{password}\n", 0.1)
        machine.succeed("xdotool mousemove 276 456 click 1")
        machine.send_chars(f"{password}\n", 0.1)
        machine.succeed("xdotool mousemove 414 550 click 1")
        machine.sleep(3)

        # Generate 'self' address
        machine.succeed("xdotool mousemove 476 521 click 1")
        machine.sleep(2)

        # Copy self address
        machine.succeed("xdotool mousemove 665 259 click 1")
        addr = machine.succeed("xclip -o -sel clipboard").strip()
        print(f"{machine.name} address: {addr}")
        return addr

      def add_peer(machine, peer_address, peer_nickname):
        # enter peer link address
        machine.succeed("xdotool mousemove 359 358 click 1")
        machine.send_chars(f"{peer_address}\n", 0.3)
        # enter peer nickname
        machine.succeed("xdotool mousemove 365 477 click 1")
        machine.send_chars(f"{peer_nickname}\n", 0.3)
        machine.sleep(2)
        # click add peer
        machine.succeed("xdotool mousemove 644 586 click 1")
        machine.sleep(2)

      peer1_address = setup_peer(peer1, "peer_uno", "peer1_foobar")
      peer2_address = setup_peer(peer2, "peer_dos", "peer2_foobar")

      add_peer(peer1, peer2_address, "peer_dos")
      # add_peer(peer2, peer1_address, "peer_uno")


      # TODO: remove. Only for debugging
      print(f"peer1 address: {peer1_address}")
      print(f"peer2 address: {peer2_address}")
    '';
}
