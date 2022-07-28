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
        in
        {
          inherit (pkgsArm)
            nitrokey-pro;
        };
    };
  };
}
