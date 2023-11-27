{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=27ead4fec31f241baed776d046b1dcac431a5919";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
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
            rustPlatform = pkgs.makeRustPlatform {
              rustc = rust;
              cargo = rust;
            };
          }
        );
        nitrokey-storage = pkgs.callPackage ./devices/nitrokey-storage.nix {};
        nitrokey-pro = pkgs.callPackage ./devices/nitrokey-pro.nix {inherit stdenvArm;};
        nitrokey-start = pkgs.callPackage ./devices/nitrokey-start.nix {gcc11StdenvArm = pkgsArm.gcc11Stdenv;};
        nitrokey-trng-rs232 = pkgs.callPackage ./devices/nitrokey-trng-rs232.nix {inherit stdenvAvr;};
      };
    };
  };
}
