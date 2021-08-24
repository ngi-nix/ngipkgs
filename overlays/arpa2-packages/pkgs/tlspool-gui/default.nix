{ src, pname, version, stdenv, lib, helpers, tlspool, qtbase, wrapQtAppsHook }:

helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [ tlspool wrapQtAppsHook ];
  buildInputs = [ qtbase ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_PREFIX_PATH=$out
  '';
}
