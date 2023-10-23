{ pkgs, stdenv, lib }:

{
  mkArpa2Derivation = { ... }@args:
    let
      defaultSet = {
        # cmake, apra2cm, and arpa2common, are almost always a dependency of a
        # project inside the bigger apra2 project. So just include them by
        # default.
        nativeBuildInputs = with pkgs; [ cmake arpa2cm arpa2common ];
      };
    in stdenv.mkDerivation (args // {
      nativeBuildInputs = defaultSet.nativeBuildInputs
        ++ (args.nativeBuildInputs or [ ]);
    });
}
