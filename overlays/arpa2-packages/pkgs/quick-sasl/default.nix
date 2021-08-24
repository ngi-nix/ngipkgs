{ src, pname, version, stdenv, helpers, quick-mem, cyrus_sasl, quick-der
, pkgconfig, libkrb5, libev, e2fsprogs }:

helpers.mkArpa2Derivation {
  inherit src pname version;

  nativeBuildInputs =
    [ libkrb5 quick-mem cyrus_sasl quick-der libev e2fsprogs ];

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_PREFIX_PATH=$out
  '';
}
