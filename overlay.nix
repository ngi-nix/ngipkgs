final: prev: {
  nitrokey-pro = prev.callPackage ./devices/nitrokey-pro.nix { };
  nitrokey-start = prev.callPackage ./devices/nitrokey-start.nix { };
  nitrokey-trng-rs232 = prev.callPackage ./devices/nitrokey-trng-rs232.nix { };
}
