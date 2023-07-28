{
  stdenv,
  gnunet,
  libsodium,
  libgcrypt,
  libgnunetchat,
  ncurses,
  fetchgit,
}:
stdenv.mkDerivation {
  name = "gnunet-messenger-cli";
  src = fetchgit {
    url = "https://git.gnunet.org/messenger-cli";
    rev = "969f1536918e342bb331acfb042bf906c307978c";
    sha256 = "sha256-y+6A70dh973qJTDy12Tgm4dvgZgPjtkqSHklP0/6YBc=";
  };

  INSTALL_DIR = (placeholder "out") + "/";

  buildInputs = [
    gnunet
    libsodium
    libgcrypt
    libgnunetchat
    ncurses
  ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  preFixup = ''
    mv $out/bin/messenger-cli $out/bin/gnunet-messenger-cli
  '';
}
