{pkgs, ...}: {
  packages = {inherit (pkgs) flarum;};
  nixos.module.service = ./service.nix;
}
