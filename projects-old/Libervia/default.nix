{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs)
      doubleratchet
      libervia-backend
      libervia-desktop-kivy
      libervia-media
      libervia-templates
      libxeddsa
      oldmemo
      omemo
      sat-tmp
      twomemo
      urwid-satext
      x3dh
      xeddsa
      ;
    inherit (pkgs.python3Packages)
      kivy-garden-modernmenu
      ;
  };
  nixos = {
    modules.programs.libervia = ./module.nix;
    tests.libervia = import ./test.nix args;
    examples = {
      base = {
        description = "Enables the use of Libervia's CLI, TUI and GUI (kivy) clients.";
        path = ./examples/base.nix;
      };
    };
  };
}
