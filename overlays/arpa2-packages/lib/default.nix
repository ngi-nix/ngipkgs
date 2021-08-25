{ pkgs, stdenv }:

{
  mkArpa2Derivation = { ... }@args:
    let
      defaultSet = {
        # cmake, apra2cm, and arpa2common, are almost always a dependency of a
        # project inside the bigger apra2 project. So just include them by
        # default.
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
