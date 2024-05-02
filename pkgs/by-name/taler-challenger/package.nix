{
  lib,
  stdenv,
  fetchgit,
  autoreconfHook,
  pkg-config,
  texinfo,
  curl,
  gnunet,
  jansson,
  libgcrypt,
  libgnurl,
  libmicrohttpd,
  libsodium,
  libtool,
  postgresql,
  taler-exchange,
  taler-merchant,
}:
stdenv.mkDerivation rec {
  pname = "taler-challenger";
  version = "0.10.0";

  src = fetchgit {
    url = "https://git.taler.net/challenger.git";
    rev = "v${version}";
    hash = "sha256-fjT3igPQ9dQtOezwZVfK5fBaL22FKOCbjUF0U1urK0g=";
  };

  # From ./bootstrap
  preAutoreconf = ''
    cd contrib
    rm -f Makefile.am
    find wallet-core/challenger/ -type f -printf '  %p \\\n' | sort > Makefile.am.ext
    # Remove extra '\' at the end of the file
    truncate -s -2 Makefile.am.ext
    cat Makefile.am.in Makefile.am.ext >> Makefile.am
    # Prevent accidental editing of the generated Makefile.am
    chmod -w Makefile.am
    cd ..
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    libgcrypt
    pkg-config
    texinfo
  ];

  buildInputs = [
    curl
    gnunet
    jansson
    libgcrypt
    libgnurl
    libmicrohttpd
    libsodium
    libtool
    postgresql
    taler-exchange
    taler-merchant
  ];

  meta = {
    description = "OAuth 2.0-based authentication service that validates user can receive messages at a certain address";
    homepage = "https://git.taler.net/challenger.git";
    license = lib.licenses.agpl3Plus;
  };
}
