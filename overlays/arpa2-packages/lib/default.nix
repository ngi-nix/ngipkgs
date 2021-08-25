{ pkgs, stdenv }:

{
  mkArpa2Derivation = { ... }@args:
    let
      defaultSet = {
        nativeBuildInputs = with pkgs; [ cmake arpa2cm arpa2common ];

        # Remove `./Makefile` since it causes the default builder to not use
        # cmake, but the default `configure && make && make install` procedure.
        postUnpack = ''
          rm -rf Makefile
        '';
      };
    in stdenv.mkDerivation (args // {
      nativeBuildInputs = defaultSet.nativeBuildInputs
        ++ (args.nativeBuildInputs or [ ]);
    });
}
