{ pkgs, stdenv }:

{
  mkArpa2Derivation = { ... }@args:
    let
      defaultDerivation = stdenv.mkDerivation {
        nativeBuildInputs = with pkgs; [ cmake arpa2cm arpa2common ];

        # Remove `./Makefile` since it causes the default builder to not use
        # cmake, but the default `configure && make && make install` procedure.
        postUnpack = ''
          rm -rf Makefile
        '';
      };
    in defaultDerivation.overrideAttrs (oldAttrs:
      (args // rec {
        nativeBuildInputs = oldAttrs.nativeBuildInputs
          ++ (args.nativeBuildInputs or [ ]);
      }));
}
