{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    overlays.default = import ./overlay.nix;

    packages = {
      x86_64-linux =
        let
          system = "x86_64-linux";
          overlays = [ self.overlays.default ];
          pkgsArm = import nixpkgs {
            inherit system overlays;
            crossSystem.config = "arm-none-eabi";
          };
          pkgsAvr = import nixpkgs {
            inherit system overlays;
            crossSystem.config = "avr";
          };
        in
        {
          inherit (pkgsArm)
            nitrokey-pro
            nitrokey-start;
          inherit (pkgsAvr)
            nitrokey-trng-rs232;
        };
    };
  };
}
