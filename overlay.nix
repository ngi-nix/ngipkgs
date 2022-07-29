final: prev: {
  nitrokey-3 = prev.callPackage ./devices/nitrokey-3.nix (
    let
      rust = prev.rust-bin.stable.latest.default.override {
        extensions = [ "llvm-tools-preview" ];
        targets = [ "thumbv8m.main-none-eabi" ];
      };
    in
    {
      rustPlatform = prev.recurseIntoAttrs (prev.makeRustPlatform {
        rustc = rust;
        cargo = rust;
      });
    }
  );
  nitrokey-pro = prev.callPackage ./devices/nitrokey-pro.nix { };
  nitrokey-start = prev.callPackage ./devices/nitrokey-start.nix { };
  nitrokey-storage = prev.callPackage ./devices/nitrokey-storage.nix { };
  nitrokey-trng-rs232 = prev.callPackage ./devices/nitrokey-trng-rs232.nix { };
}
