{
  stdenv,
  fetchgit,
  # Build tools:
  meson,
  ninja,
  pkg-config,
  # Dependencies:
  gnunet,
  libsodium,
  libgcrypt,
  libgnunetchat,
  ncurses,
}:
stdenv.mkDerivation rec {
  pname = "gnunet-messenger-cli";
  version = "0.3.0";

  src = fetchgit {
    url = "https://git.gnunet.org/messenger-cli";
    rev = "v${version}";
    hash = "sha256-Z6P1V/nkB64dPcyEMd/mmkee1wd0FvDjErIL9HEZvwk=";
  };

  INSTALL_DIR = (placeholder "out") + "/";

  nativeBuildInputs = [meson ninja pkg-config];

  buildInputs = [
    gnunet
    libgcrypt
    libgnunetchat
    libsodium
    ncurses
  ];

  preInstall = "mkdir -p $out/bin";

  preFixup = "mv $out/bin/messenger-cli $out/bin/gnunet-messenger-cli";
}
