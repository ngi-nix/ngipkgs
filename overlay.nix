final: prev: {
  nitrokey-pro = prev.callPackage ./devices/nitrokey-pro.nix { };
  nitrokey-start = prev.callPackage ./devices/nitrokey-start.nix { };
  nitrokey-storage = prev.callPackage ./devices/nitrokey-storage.nix { };
  nitrokey-trng-rs232 = prev.callPackage ./devices/nitrokey-trng-rs232.nix { };
}
