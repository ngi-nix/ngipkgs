{pkgs, ...}: {
  packages = {inherit (pkgs) flarum;};
  nixos.modules.service = {
    path = ./service.nix;
    options = "services\\.flarum\\..*";
  };
}
