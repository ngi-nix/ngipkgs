{ stdenv, ... }:
let
  pname = "social";
in
finalMixPkgs: previousMixPkgs: {
  ${pname} =
    (previousMixPkgs.${pname} or (stdenv.mkDerivation { name = "${pname}-dummy"; })).overrideAttrs
      (previousAttrs: {
        # Explanation: social list rustler_precompiled as a dependency in deps.hex,
        # letting deps_nix believe it needs it,
        # and thus expecting a native/ directory with a Rust crate.
        # This is not the case, so remove the problematic part.
        preConfigure = "";
      });
}
