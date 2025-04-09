{
  stdenv,
  fetchgit,
  pkg-config,
  autoreconfHook,
  taler-exchange,
  taler-merchant,
  libgcrypt,
  libmicrohttpd,
  jansson,
  libsodium,
  postgresql,
  curl,
  recutils,
  libuuid,
  lib,
  gnunet,
  makeWrapper,
  jq,
  texinfo,
  which,
  callPackage,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "anastasis";
  version = "0.6.1-unstable-2025-03-02";

  src = fetchgit {
    url = "https://git.taler.net/anastasis.git";
    rev = "e35b82a7d597403fefa753598def3bc316d64e76";
    hash = "sha256-P82yhdYaUYxFoQgyHsQJwMPGGnVois3/1huKSwDD7is=";
  };

  postPatch = ''
    patchShebangs contrib src/cli
    ./contrib/gana-update.sh
  '';

  outputs = [
    "out"
    "configured"
  ];

  nativeBuildInputs = [
    pkg-config # hook that adds pkg-config files of buildInputs
    autoreconfHook # hook that triggers autoreconf to get the configure script
    makeWrapper # for wrapProgram
    jq
    texinfo
  ];

  buildInputs = [
    taler-exchange
    taler-merchant
    libgcrypt
    libmicrohttpd
    libsodium
    postgresql
    curl
    jansson
    recutils
    libuuid
  ];

  configureFlags = [
    "--with-gnunet=${gnunet}"
    "--with-exchange=${taler-exchange}"
    "--with-merchant=${taler-merchant}"
  ];

  postConfigure = ''
    mkdir -p $configured
    cp -r ./* $configured/
  '';

  postInstall = ''
    wrapProgram $out/bin/anastasis-config --prefix PATH : ${
      lib.makeBinPath [
        # Fix "anastasis-config-wrapped needs gnunet-config to be installed"
        #   in src/cli/test_anastasis_reducer_backup_enter_user_attributes.sh
        # (NB: --with-gnunet was not enough)
        gnunet
        # needed by $out/bin/anastasis-config during postInstallCheck
        which
      ]
    }
  '';

  doInstallCheck = true;

  # Check that anastasis-config can find gnunet at runtime
  installCheckPhase = ''
    runHook preInstallCheck

    output=$($out/bin/anastasis-config --help || true)
    echo "$output" | grep "Report bugs to contact@anastasis.lu."

    runHook postInstallCheck
  '';

  passthru.tests.vmTest = callPackage ./test.nix { };

  meta = {
    description = ''
      GNU Anastasis is a key backup and recovery tool from the GNU project.
      This package includes the backend run by the Anastasis providers as
      well as libraries for clients and a command-line interface.
    '';
    license = lib.licenses.agpl3Plus; # from the README
    homepage = "https://anastasis.lu";
  };
})
