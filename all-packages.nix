{newScope, ...}: let
  self = rec {
    libgnunetchat = callPackage ./pkgs/libgnunetchat {};
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli {};
    liberaforms = callPackage ./pkgs/liberaforms {};
    liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};
    kikit = callPackage ./pkgs/kikit {};
  };

  nixpkgs-candidates = {
    pcbnew-transition = callPackage ./nixpkgs-candidates/pcbnew-transition {};
    pybars3 = callPackage ./nixpkgs-candidates/pybars3 {};
    pymeta3 = callPackage ./nixpkgs-candidates/pymeta3 {};
    euclid3 = callPackage ./nixpkgs-candidates/euclid3 {};
  };

  callPackage = newScope (self // nixpkgs-candidates // {inherit callPackage;});
in
  self
