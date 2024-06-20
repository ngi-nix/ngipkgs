{pkgs, ...}: {
  packages = {inherit (pkgs) atomic-server;};
  nixos.modules.services.atomic-server = ./service.nix;
}
