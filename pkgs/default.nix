{
  lib,
  callPackage,
}: let
  inherit
    (lib)
    recurseIntoAttrs
    ;

  self = rec {
    # LiberaForms is intentionally disabled.
    # Refer to <https://github.com/ngi-nix/ngipkgs/issues/40>.
    #liberaforms = callPackage ./pkgs/liberaforms {};
    #liberaforms-env = callPackage ./pkgs/liberaforms/env.nix {};
  };
in
  self
