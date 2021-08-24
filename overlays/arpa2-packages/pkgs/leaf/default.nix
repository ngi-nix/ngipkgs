{ src, pname, version, stdenv, helpers, quick-der, lillydap }:

helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [ quick-der lillydap ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out
  '';
}
