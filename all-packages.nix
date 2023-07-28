{newScope, ...}: let
  self = rec {
    libgnunetchat = callPackage ./pkgs/libgnunetchat {};
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli {};
    liberaforms = callPackage ./pkgs/liberaforms {};
    liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};
  };

  callPackage = newScope self;
in
  self
