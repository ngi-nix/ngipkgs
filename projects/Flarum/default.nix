{pkgs, ...}: {
  packages = {inherit (pkgs) flarum;};
  nixos.modules.services.flarum = ./service.nix;
}
