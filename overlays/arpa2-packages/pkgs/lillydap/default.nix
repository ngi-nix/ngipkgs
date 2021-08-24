{ src, pname, version, stdenv, helpers, quick-der, gperf }:

helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs = [ quick-der gperf ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out
  '';
}
