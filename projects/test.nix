{
  lib,
  pkgs,
}:
test:
let
  # Amenities for interactive tests
  tools =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        vim
        tmux
        jq
      ];
      # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
      # to provide a slightly nicer console.
      # kmscon allows zooming with [Ctrl] + [+] and [Ctrl] + [-]
      services.kmscon = {
        enable = true;
        autologinUser = "root";
      };
    };
  debugging.interactive.nodes = lib.mapAttrs (_: _: tools) test.nodes;
in
pkgs.nixosTest (debugging // test)
