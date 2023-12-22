{
  src,
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
  jq,
  git,
}: let
  gnunet' = gnunet.override {postgresqlSupport = true;};
in
  stdenv.mkDerivation rec {
    pname = "anastasis";
    version = "0.4.0";
    src = fetchzip {
      url = "https://git.taler.net/anastasis.git/snapshot/${pname}-${version}.tar.gz";
      sha256 = "sha256-zSjFYjlYQEhX2Uwd2qx3z1LGuHA/glBiH98XfrGoJlg=";
    };
    postPatch = ''
      patchShebangs src/cli
      patchShebangs bootstrap
      patchShebangs contrib
    '';
    outputs = ["out" "configured"];
    nativeBuildInputs = [
      pkg-config # hook that adds pkg-config files of buildInputs
      autoreconfHook # hook that triggers autoreconf to get the configure script
      makeWrapper # for wrapProgram
      jq # used by extract.sh
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
      "--with-gnunet=${gnunet'}"
      "--with-exchange=${taler-exchange}"
      "--with-merchant=${taler-merchant}"
    ];
    postConfigure = ''
      mkdir -p $configured
      cp -r ./* $configured/
      ./contrib/gana-update.sh
    '';

    preBuild = ''
      # ./bootstrap

    '';

    postInstall = ''
      wrapProgram $out/bin/anastasis-config --prefix PATH : ${lib.makeBinPath [
        # Fix "anastasis-config-wrapped needs gnunet-config to be installed"
        #   in src/cli/test_anastasis_reducer_backup_enter_user_attributes.sh
        # (NB: --with-gnunet was not enough)
        gnunet'
        # needed by $out/bin/anastasis-config during postInstallCheck
        which
      ]}
    '';
    doInstallCheck = true;
    postInstallCheck = ''
      # The author said `make check` is meant to be executed after installation
      # FIXME: many tests are skipped
      make check
      # Check that anastasis-config can find gnunet at runtime
      $out/bin/anastasis-config --help > /dev/null
    '';
    meta = {
      description = ''
        GNU Anastasis is a key backup and recovery tool from the GNU project.
        This package includes the backend run by the Anastasis providers as
        well as libraries for clients and a command-line interface.
      '';
      license = lib.licenses.agpl3Plus; # from the README
      homepage = "https://anastasis.lu";
    };
  }
