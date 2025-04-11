{
  lib,
  pkgs,
  sources,
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
      module = "${sources.inputs.nixpkgs}/nixos/modules/services/networking/wireguard.nix";
      examples.basic = null;
    };
  };

  nixos.tests =
    lib.foldl'
      (acc: test: acc // { ${test} = "${sources.inputs.nixpkgs}/nixos/tests/wireguard/${test}.nix"; })
      { }
      [
        "basic"
        "namespaces"
        "wg-quick"
        "generated"
      ];
}
