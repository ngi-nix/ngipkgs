{
  lib,
  pkgs,
  sources,
  ...
}@args:

{
  metadata = {
    summary = "fast and modern VPN that utilizes state-of-the-art cryptography";
    subgrants = {
      Entrust = [
        "KlusterLab-Wireguard"
        "WireGuard-SpinalHDL"
      ];
      Review = [
        "WireGuard-upscale"
        "WireGuardonWindows"
        "Wireguard-Rust"
        "wireguard"
        "wireguard-scaleup"
      ];
    };
  };

  nixos.modules.programs = {
    wireguard = {
      module = ./program/module.nix;
      examples.basic = {
        module = ./program/example.nix;
        description = "";
        tests.basic.module = null;
      };
    };
  };

  nixos.modules.services = {
    wireguard = {
      module = lib.moduleLocFromOptionString "networking.wireguard";
      examples.basic.module = null;
    };
  };
  nixos.tests =
    let
      nixosTests = lib.mapAttrs (_: test: {
        module = test;
      }) pkgs.nixosTests.wireguard;
    in
    lib.recursiveUpdate nixosTests {
      # FIX:
      "wireguard-dynamic-refresh-networkd-linux-latest" = {
        problem.broken.reason = ''
          https://buildbot.ngi.nixos.org/#/builders/987/builds/1
        '';
      };
    };
}
