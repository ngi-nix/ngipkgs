let
pkgs = import (fetchTarball https://github.com/NixOS/nixpkgs/tarball/7e0743a5aea1dc755d4b761daf75b20aa486fdad) {};
  lib = pkgs.lib;
  packages = import ./all-packages.nix { inherit (pkgs) newScope; };
  ngipkgsModule = { ... }: {
    _module.args.ngipkgs = packages;
  };
in
# nix-build -A toplevel
pkgs.nixos ({ ... }:
{
  imports = [
    ./configs/liberaforms/container.nix
    ngipkgsModule
  ];
})
