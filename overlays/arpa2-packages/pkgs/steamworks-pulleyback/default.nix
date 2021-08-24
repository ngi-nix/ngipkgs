{ src, pname, version, stdenv, helpers, steamworks, lua, doxygen, graphviz
, libressl, lmdb, libuuid }:

helpers.mkArpa2Derivation {
  inherit src pname version;

  buildInputs = [ steamworks lua doxygen graphviz libuuid ];

  patches = [ ./install-dirs.patch ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out \
             -DCMAKE_PREFIX_PATH=$out \
             -DPULLEY_BACKEND_DIR=$out/share/steamworks/pulleyback/
  '';
}
