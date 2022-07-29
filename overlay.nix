final: prev: {
  nitrokey-pro = prev.callPackage ./devices/nitrokey-pro.nix { };
  nitrokey-start = prev.callPackage ./devices/nitrokey-start.nix { };
}
