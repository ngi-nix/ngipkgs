{src, stdenv, fetchzip, pkg-config, autoreconfHook, taler-exchange, taler-merchant, libgcrypt,
libmicrohttpd, jansson, libsodium, postgresql, curl, recutils, libuuid, lib, gnunet, makeWrapper, which, jq}:
let
  gnunet' = gnunet.override { postgresqlSupport = true; };
in
stdenv.mkDerivation rec {
  pname = "anastasis";
  version = "0.0.0";
  # version = "0.1.0"; # needs gnunet 0.15.3 and conflicts with taler-exchange 0.8.4: missing TALER_amount_is_zero
  src = fetchzip {
    url = "mirror://gnu/anastasis/${pname}-${version}.tar.gz";
    sha256 = "sha256-srsPrwSJgjLJI1zVnOJY8eoXnsIg/mfJyJ14TqSc99E=";
  };

  postPatch = ''
    for f in src/cli/*.sh; do
      substituteInPlace "$f" --replace "#!/bin/bash" "#!${stdenv.shell}";
    done
  '';
  nativeBuildInputs = [
    # To get the pkgconfig file into the dev output of taler-exchange
    # https://nixos.wiki/wiki/C#pkg-config
    # https://discourse.nixos.org/t/how-to-add-pkg-config-file-to-a-nix-package/8264
    # https://discourse.nixos.org/t/could-weve-implemented-multi-output-packages-better/6597
    pkg-config
    autoreconfHook
    # for wrapProgram
    makeWrapper
  ];
  buildInputs = [
    taler-exchange
    taler-merchant
    libgcrypt
    libmicrohttpd
    jansson
    libsodium
    postgresql
    curl
    recutils
    libuuid
  ];
  configureFlags = [
    # GNUNETPFX
    "--with-gnunet=${gnunet'}"
    # EXCHANGEPFX
    "--with-exchange=${taler-exchange}"
  ];
  # FIXME: this increases computation time
  # see https://github.com/gytis-ivaskevicius/rfcs/blob/enable-docheck-by-default/rfcs/0095-enable-docheck-by-default.md
  # FIXME: many tests are skipped 
  #   it might be needed to add ./ in front of some shell scripts within test scripts, missing path to config
  checkInputs = [
    taler-exchange
    taler-merchant
    jq
  ];
  doCheck = true;

  postInstall = ''
    # FIXME I don't know if it's necessary if the GNUNETPREFIX is already set
    wrapProgram $out/bin/anastasis-config --prefix PATH : ${lib.makeBinPath [
      # Fix "anastasis-config-wrapped needs gnunet-config to be installed"
      #   in src/cli/test_anastasis_reducer_backup_enter_user_attributes.sh
      # (NB: --with-gnunet was not enough)
      gnunet'
      # `which` is needed by $out/bin/anastasis-config during postInstallCheck
      which
    ]}
    '';
  doInstallCheck = true;
  postInstallCheck = ''
    # Check that anastasis-config can find gnunet at runtime
    $out/bin/anastasis-config --help > /dev/null
    '';
  meta = {
    description = ''
      GNU Anastasis is a key backup and recovery tool from the GNU project.
      This package includes the backend run by the Anastasis providers as
      well as libraries for clients and a command-line interface.
    '';
    license = lib.licenses.agpl3Only;
    homepage = "https://anastasis.lu";
  };
}
