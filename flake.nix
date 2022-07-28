{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    overlays.default = import ./overlay.nix;

    packages = {
      x86_64-linux = { };
    };
  };
}
