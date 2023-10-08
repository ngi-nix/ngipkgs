{
  dream2nix,
  pkgs,
}: let
  packages = dream2nix.lib.importPackages {
    projectRoot = ./.;
    projectRootFile = "package.nix";
    packagesDir = ./packages;
    packageSets.nixpkgs = pkgs;
  };
in
  builtins.head (builtins.attrValues packages)
