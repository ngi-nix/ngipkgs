let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  packages = import ./all-packages.nix { inherit (pkgs) newScope; };
  overlayModule = { ... }: {
    nixpkgs.overlays = [ (final: prev: packages) ];
  };
in
{ ... }:
{
  imports = [
    ./configs/liberaforms/container.nix
    overlayModule
  ];
}
