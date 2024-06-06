{pkgs, ...}: {
  packages = ["flarum"];
  nixos.modules.services.flarum = null;
}
