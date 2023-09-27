{
  newScope,
  lib,
  ...
}: let
  self = let
    pretalxPlugins = lib.recurseIntoAttrs (callPackage ./pkgs/pretalx/plugins.nix {});
  in rec {
    atomic-cli = callPackage ./pkgs/atomic-cli {};
    atomic-server = callPackage ./pkgs/atomic-server {};
    flarum = callPackage ./pkgs/flarum {};
    gnunet-messenger-cli = callPackage ./pkgs/gnunet-messenger-cli {};
    kikit = callPackage ./pkgs/kikit {};
    lcrq = callPackage ./pkgs/lcrq {};
    lcsync = callPackage ./pkgs/lcsync {inherit lcrq librecast;};

    # LiberaForms is intentionally disabled.
    # Refer to <https://github.com/ngi-nix/ngipkgs/issues/40>.
    #liberaforms = callPackage ./pkgs/liberaforms {};
    #liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};

    libgnunetchat = callPackage ./pkgs/libgnunetchat {};
    librecast = callPackage ./pkgs/librecast {inherit lcrq;};
    pretalx = callPackage ./pkgs/pretalx {};
    pretalx-frontend = callPackage ./pkgs/pretalx/frontend.nix {};
    pretalx-full = callPackage ./pkgs/pretalx {
      withPlugins = [
        pretalx-downstream
        pretalx-media-ccc-de
        pretalx-pages
      ];
    };

    inherit
      (pretalxPlugins)
      pretalx-downstream
      pretalx-media-ccc-de
      pretalx-pages
      ;

    rosenpass = callPackage ./pkgs/rosenpass {};
    rosenpass-tools = callPackage ./pkgs/rosenpass-tools {};
  };

  nixpkgs-candidates = {
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    pcbnew-transition = callPackage ./nixpkgs-candidates/pcbnew-transition {};
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    pybars3 = callPackage ./nixpkgs-candidates/pybars3 {};
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    pymeta3 = callPackage ./nixpkgs-candidates/pymeta3 {};
    # Attempting to upstream to nixpkgs here: https://github.com/NixOS/nixpkgs/pull/249464
    euclid3 = callPackage ./nixpkgs-candidates/euclid3 {};
  };

  callPackage = newScope (self // nixpkgs-candidates // {inherit callPackage;});
in
  self
