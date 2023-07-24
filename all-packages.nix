{ newScope, ... }:
let
  self = rec {
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli { };
    liberaforms = callPackage ./pkgs/liberaforms { };
    liberaforms-env = callPackage ./pkgs/liberaforms/env.nix { };
    libgnunetchat = callPackage ./pkgs/libgnunetchat { };
  };

  callPackage = newScope self;
in
self
