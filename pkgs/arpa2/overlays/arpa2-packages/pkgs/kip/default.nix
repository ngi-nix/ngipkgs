{
  src,
  pname,
  version,
  stdenv,
  cmake,
  pkg-config,
  arpa2cm,
  arpa2common,
  quickmem,
  quickder,
  quicksasl,
  unbound,
  openssl,
  e2fsprogs,
  cyrus_sasl,
  libkrb5,
  libev,
  json_c,
  bison,
  flex,
  freeDiameter,
  python3,
  libressl,
  cacert,
  gnutls,
}: let
  python-with-packages =
    python3.withPackages
    (ps: with ps; [setuptools asn1ate six pyparsing colored]);
  libkrb5' = libkrb5.overrideAttrs (old: {
    # kip needs the symbol `_et_list` associated with the com_err library.
    # This is provided by e2fsprogs.
    # Another dependency of kip, libkrb5, also provides the com_err library,
    # but a version of it that doesn't provide `_et_list`.
    # Without intervention, com_err from libkrb5 is selected, failing the build.
    #
    # Exclude com_err from libkrb5's outputs.
    configureFlags = old.configureFlags ++ ["--with-system-et"];

    # Provide libkrb5 with the com_err library.
    buildInputs = old.buildInputs ++ [e2fsprogs];
  });
in
  stdenv.mkDerivation {
    inherit src pname version;

    nativeBuildInputs = [cmake pkg-config cacert openssl libressl gnutls];

    buildInputs = [
      arpa2cm
      arpa2common
      quickmem
      quickder
      quicksasl
      unbound
      e2fsprogs
      cyrus_sasl
      libkrb5'
      libev
      json_c
      bison
      flex
      freeDiameter
      python-with-packages
    ];

    configurePhase = ''
      mkdir -p build
      cd build
      cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_PREFIX_PATH=$out \
            -DfreeDiameter_EXTENSION_DIR=$out/lib/freeDiameter
      patchShebangs test
    '';

    buildPhase = ''
      cmake --build .
    '';

    installPhase = ''
      cmake --install . --prefix $out
    '';
  }
