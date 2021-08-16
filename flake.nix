{
  description = "Weblate package and module";

  inputs.nixpkgs.url = "github:NixOS/Nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix/1.18.0";
  inputs.weblate.url = "git+file:///home/kerstin/git/weblate?ref=weblate-4.7.2-poetry";
  inputs.weblate.flake = false;

  outputs = { self, nixpkgs, poetry2nix, weblate }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ poetry2nix.overlay ];
      };
    in
    {

      packages.x86_64-linux.weblate = pkgs.poetry2nix.mkPoetryApplication {
        projectDir = ./.;
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.weblate;

    };
}
