{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "fast and modern VPN that utilizes state-of-the-art cryptography";
    subgrants = [
      "KlusterLab-Wireguard"
      "WireGuard-SpinalHDL"
      "WireGuard-upscale"
      "WireGuardonWindows"
      "Wireguard-Rust"
      "wireguard"
      "wireguard-scaleup"
    ];
  };

  nixos.modules.programs = {
    wireguard = {
      module = ./program/module.nix;
      examples.basic = {
        module = ./program/example.nix;
        description = "";
        tests.basic = null;
      };
    };
  };

  nixos.modules.services = {
    wireguard = {
      module = lib.moduleLocFromOptionString "networking.wireguard";
      examples.basic.module = null;
    };
  };

  nixos.tests = lib.removeAttrs pkgs.nixosTests.wireguard [
    # FIX: https://buildbot.ngi.nixos.org/#/builders/987/builds/1
    "wireguard-dynamic-refresh-networkd-linux-latest"
  ];
}
