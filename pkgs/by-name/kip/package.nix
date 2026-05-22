{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  pkg-config,
  arpa2cm,
  arpa2common,
  quickmem,
  quickder,
  quick-sasl,
  unbound,
  openssl,
  e2fsprogs,
  cyrus_sasl,
  libkrb5,
  libev,
  json_c,
  bison,
  flex,
  freediameter,
  python3,
  libressl,
  cacert,
  gnutls,
  nix-update-script,
}:
let
  python-with-packages = python3.withPackages (
    ps: with ps; [
      setuptools
      asn1ate
      six
      pyparsing
      colored
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kip";
  version = "0.15.0";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "kip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A+tPaImjd9j1Vq69Dgh3j86xI/OcovwTZSULLkOVZaI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    cacert
    openssl
    libressl
    gnutls
  ];

  buildInputs = [
    arpa2cm
    arpa2common
    quickmem
    quickder
    quick-sasl
    unbound
    e2fsprogs
    cyrus_sasl
    libkrb5
    libev
    json_c
    bison
    flex
    freediameter
    python-with-packages
  ];

  cmakeFlags = [
    (lib.cmakeFeature "freeDiameter_EXTENSION_DIR" "${placeholder "out"}/lib/freeDiameter")
  ];

  preBuild = ''
    patchShebangs test
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Keyful Identity Protocol — symmetric-key encryption and signing via an online KIP Service";
    homepage = "https://gitlab.com/arpa2/kip";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    teams = with lib.teams; [ ngi ];
  };
})
