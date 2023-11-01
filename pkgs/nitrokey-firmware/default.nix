{inputs}: let
  system = "x86_64-linux";
  overlays = [inputs.rust-overlay.overlays.default];
  pkgs = import inputs.nixpkgs {
    inherit system overlays;
  };
  pkgsArm = import inputs.nixpkgs {
    inherit system overlays;
    crossSystem.config = "arm-none-eabi";
    config.allowUnfree = true; # nitrokey-fido2 → pynitrokey → nrfutil
  };
  pkgsAvr = import inputs.nixpkgs {
    inherit system overlays;
    crossSystem.config = "avr";
  };
in {
  nitrokey-3 = pkgs.callPackage ./devices/nitrokey-3.nix (
    let
      rust = pkgs.rust-bin.stable.latest.default.override {
        extensions = ["llvm-tools-preview"];
        targets = ["thumbv8m.main-none-eabi"];
      };
    in {
      rustPlatform = pkgs.recurseIntoAttrs (pkgs.makeRustPlatform {
        rustc = rust;
        cargo = rust;
      });
    }
  );
  nitrokey-storage = pkgs.callPackage ./devices/nitrokey-storage.nix {};
  nitrokey-fido2 = pkgsArm.callPackage ./devices/nitrokey-fido2.nix {};
  nitrokey-pro = pkgsArm.callPackage ./devices/nitrokey-pro.nix {};
  nitrokey-start = pkgsArm.callPackage ./devices/nitrokey-start.nix {};
  nitrokey-trng-rs232 = pkgsAvr.callPackage ./devices/nitrokey-trng-rs232.nix {};
}
