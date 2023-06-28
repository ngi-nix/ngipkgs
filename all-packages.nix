{ newScope, ... }:
let
  self = rec {
    libgnunetchat = callPackage ./pkgs/libgnunetchat { };
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli { };
    liberaforms = callPackage ./pkgs/liberaforms { };
    liberaforms-env = callPackage ./pkgs/liberaforms/env.nix { };
    #default = throw "NGIPkgs does not export any default package.";
    default = liberaforms;
  };

  callPackage = newScope self;
in
self
