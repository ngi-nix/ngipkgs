{pkgs, ...}: {
  packages = {inherit (pkgs) vula;};
  nixos.modules.services.vula = ./service.nix;
}
