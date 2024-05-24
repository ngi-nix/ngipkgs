{pkgs, ...}: {
  packages = {inherit (pkgs) flarum;};
  nixos.modules.services.flarum = null;
}
