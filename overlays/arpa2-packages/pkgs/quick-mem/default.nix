{ src, pname, version, stdenv, helpers }:

helpers.mkArpa2Derivation {
  inherit src pname version;

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_PREFIX_PATH=$out
  '';
}
