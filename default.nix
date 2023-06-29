let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  packages = import ./all-packages.nix { inherit (pkgs) newScope; };
  overlayModule = { ... }: {
    nixpkgs.overlays = [ (final: prev: packages) ];
  };
in
# nix-build configuration.nix -A toplevel
pkgs.nixos ({ ... }:
{
  imports = [
    ./configs/liberaforms/container.nix
    overlayModule
  ];
})
