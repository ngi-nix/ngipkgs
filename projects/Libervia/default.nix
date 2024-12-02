{
  pkgs,
  lib,
  sources,
}@args:
{
  packages = {
    inherit (pkgs)
      doubleratchet
      helium
      kivy-garden-modernmenu
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
      wokkel
      x3dh
      xeddsa
      ;
  };
  nixos = {
    modules.programs.libervia = ./module.nix;
    tests.libervia = import ./test.nix args;
    examples = rec {
      base = {
        description = "Enables the use of Libervia's CLI, TUI and GUI (kivy) clients.";
        path = ./examples/base.nix;
      };
    };
  };
}
