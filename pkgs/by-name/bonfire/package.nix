{ lib, callPackage }:
let
  generic = callPackage ./generic.nix { };
in
lib.recurseIntoAttrs (
  lib.genAttrs
    [
      # FixMe(+completeness): enable when fixed upstream.
      # Issue: https://github.com/bonfire-networks/bonfire-app/issues/1737
      #"community"
      # FixMe(+completeness): generate deps.nix
      #"cooperation"
      #"coordination"
      "ember"
      "open_science"
      "social"
    ]
    (
      flavour:
      generic.overrideAttrs (previousAttrs: {
        passthru = lib.recursiveUpdate previousAttrs.passthru {
          env.FLAVOUR = flavour;
        };
      })
    )
)
