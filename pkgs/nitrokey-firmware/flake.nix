{
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:sbruder/nixpkgs/polkit-cross-fix";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, rust-overlay }: {
    overlays.default = import ./overlay.nix;

    packages = {
      x86_64-linux =
        let
          system = "x86_64-linux";
          overlays = [ rust-overlay.overlays.default self.overlays.default ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          pkgsArm = import nixpkgs {
            inherit system overlays;
            crossSystem.config = "arm-none-eabi";
            config.allowUnfree = true; # nitrokey-fido2 → pynitrokey → nrfutil
          };
          pkgsAvr = import nixpkgs {
            inherit system overlays;
            crossSystem.config = "avr";
          };
        in
        {
          inherit (pkgs)
            nitrokey-3
            nitrokey-storage;
          inherit (pkgsArm)
            nitrokey-fido2
            nitrokey-pro
            nitrokey-start;
          inherit (pkgsAvr)
            nitrokey-trng-rs232;
        };
    };
  };
}
