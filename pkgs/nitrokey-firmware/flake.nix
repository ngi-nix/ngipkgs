{
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:sbruder/nixpkgs/polkit-cross-fix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
  }: {
    packages = {
      x86_64-linux = let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgsWithRust = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default];
        };
        pkgsArm = import nixpkgs {
          inherit system;
          crossSystem.config = "arm-none-eabi";
          config.allowUnfree = true; # nitrokey-fido2 → pynitrokey → nrfutil
        };
        pkgsAvr = import nixpkgs {
          inherit system;
          crossSystem.config = "avr";
        };
        stdenvArm = pkgsArm.stdenv;
        stdenvAvr = pkgsAvr.stdenv;
      in {
        nitrokey-3 = pkgs.callPackage ./devices/nitrokey-3 (
          let
            rust = pkgsWithRust.rust-bin.stable.latest.default.override {
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
        nitrokey-fido2 = pkgs.callPackage ./devices/nitrokey-fido2.nix {inherit stdenvArm;};
        nitrokey-pro = pkgs.callPackage ./devices/nitrokey-pro.nix {inherit stdenvArm;};
        nitrokey-start = pkgs.callPackage ./devices/nitrokey-start.nix {inherit stdenvArm;};
        nitrokey-trng-rs232 = pkgs.callPackage ./devices/nitrokey-trng-rs232.nix {inherit stdenvAvr;};
      };
    };
  };
}
