{
  stdenv,
  fetchzip,
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
  which,
  callPackage,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "anastasis";
  version = "0.4.1";

  src = fetchzip {
    url = "mirror://gnu/anastasis/anastasis-${finalAttrs.version}.tar.gz";
    hash = "sha256-nuNRZTzp/hlV3Eo2nQH4G3sGsws5Qy2nk3m99aY0L84=";
  };

  postPatch = ''
    patchShebangs src/cli
  '';

  outputs = ["out" "configured"];

  nativeBuildInputs = [
    pkg-config # hook that adds pkg-config files of buildInputs
    autoreconfHook # hook that triggers autoreconf to get the configure script
    makeWrapper # for wrapProgram
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
    wrapProgram $out/bin/anastasis-config --prefix PATH : ${lib.makeBinPath [
      # Fix "anastasis-config-wrapped needs gnunet-config to be installed"
      #   in src/cli/test_anastasis_reducer_backup_enter_user_attributes.sh
      # (NB: --with-gnunet was not enough)
      gnunet
      # needed by $out/bin/anastasis-config during postInstallCheck
      which
    ]}
  '';

  doInstallCheck = true;

  # Check that anastasis-config can find gnunet at runtime
  installCheckPhase = ''
    runHook preInstallCheck

    output=$($out/bin/anastasis-config --help || true)
    echo "$output" | grep "Report bugs to contact@anastasis.lu."

    runHook postInstallCheck
  '';

  passthru.tests.vmTest = callPackage ./test.nix {};

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
