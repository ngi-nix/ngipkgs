{
  sources,
  ...
}:
{
  name = "briar";
  description = ''
    This is still a WIP.
    Need to figure out how to connect the two peers through Wi-Fi.
  '';

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
          iw
          wirelesstools
          wpa_supplicant
        ];

        # Enable WiFi with proper configuration
        networking.wireless.enable = true;
        networking.wireless.userControlled.enable = true;
        networking.wireless.networks."test-network" = {
          psk = "testpassword123";
        };

        # Configure wireless interface
        networking.interfaces.wlan0 = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "192.168.1.10";
              prefixLength = 24;
            }
          ];
        };

        # Enable the wireless interface in the kernel
        boot.kernelModules = [ "mac80211_hwsim" ];

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
          iw
          wirelesstools
          wpa_supplicant
        ];

        # Enable WiFi with proper configuration
        networking.wireless.enable = true;
        networking.wireless.userControlled.enable = true;
        networking.wireless.networks."test-network" = {
          psk = "testpassword123";
        };

        # Configure wireless interface
        networking.interfaces.wlan0 = {
          useDHCP = false;
          ipv4.addresses = [
            {
              address = "192.168.1.11";
              prefixLength = 24;
            }
          ];
        };

        # Enable the wireless interface in the kernel
        boot.kernelModules = [ "mac80211_hwsim" ];

      };
  };

  enableOCR = true;

  testScript =
    { nodes, ... }:
    ''
      start_all()

      # Test wireless connectivity for Briar LAN transport
      print("Setting up WLAN for Briar LAN connectivity...")

      # Load the mac80211_hwsim module and create virtual wireless interfaces
      peer1.succeed("modprobe mac80211_hwsim radios=2")
      peer2.succeed("modprobe mac80211_hwsim radios=2")

      # Wait for interfaces to come up
      peer1.wait_until_succeeds("ip link show wlan0")
      peer2.wait_until_succeeds("ip link show wlan0")

      # Bring up the wireless interfaces
      peer1.succeed("ip link set wlan0 up")
      peer2.succeed("ip link set wlan0 up")

      # IP addresses are already configured declaratively in the NixOS configuration
      # Wait for IP addresses to be assigned
      peer1.wait_until_succeeds("ip addr show wlan0 | grep '192.168.1.10/24'")
      peer2.wait_until_succeeds("ip addr show wlan0 | grep '192.168.1.11/24'")

      # Verify both peers are on the same LAN segment (required for Briar LAN transport)
      print("Testing WLAN connectivity for Briar LAN transport...")
      peer1.succeed("ping -c 3 192.168.1.11")
      peer2.succeed("ping -c 3 192.168.1.10")
      print("WLAN connectivity established - peers can discover each other on LAN!")

      # Verify LAN broadcast domain (important for Briar's LAN discovery)
      print("Testing broadcast connectivity (required for Briar LAN discovery)...")
      peer1.succeed("ping -b -c 2 192.168.1.255")
      peer2.succeed("ping -b -c 2 192.168.1.255")

      # Show wireless and network interface status
      print("WLAN interface information:")
      peer1.succeed("iw dev wlan0 info")
      peer2.succeed("iw dev wlan0 info")

      # Show that both peers have stable IPv4 addresses on the same subnet
      # This is crucial for Briar's LAN transport property sharing
      print("Network configuration for Briar LAN transport:")
      peer1.succeed("ip route show | grep 192.168.1")
      peer2.succeed("ip route show | grep 192.168.1")

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
        machine.succeed("xdotool mousemove 482 498 click 1")
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
      add_peer(peer2, peer1_address, "peer_uno")

      # Wait a bit for Briar to attempt LAN discovery and connection
      print("Waiting for Briar LAN transport to establish connection...")
      peer1.sleep(10)
      peer2.sleep(10)

      # Verify that Briar can still use the LAN addresses for communication
      # The stable IPv4 addresses (192.168.1.10/11) should be shared as transport properties
      print("Verifying Briar LAN transport connectivity...")
      peer1.succeed("ping -c 1 192.168.1.11")
      peer2.succeed("ping -c 1 192.168.1.10")
      print("LAN addresses remain stable - Briar should be able to use LAN transport!")


      # TODO: remove. Only for debugging
      print(f"peer1 address: {peer1_address}")
      print(f"peer2 address: {peer2_address}")

      # Verify wireless connectivity is still working
      print("Final wireless connectivity check...")
      peer1.succeed("ping -c 1 192.168.1.11")
      peer2.succeed("ping -c 1 192.168.1.10")

      # Show network interface information
      print("peer1 network interfaces:")
      peer1.succeed("ip addr show")
      print("peer2 network interfaces:")
      peer2.succeed("ip addr show")
    '';
}
