{ newScope, ... }:
let
  self = rec {
    libgnunetchat = callPackage ./pkgs/libgnunetchat { };
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli { };
    #Disabled because IFD# liberaforms = callPackage ./pkgs/liberaforms { };
    #Disabled because IDF# liberaforms-env = callPackage ./pkgs/liberaforms/env.nix { };
  };

  callPackage = newScope self;
in
self
