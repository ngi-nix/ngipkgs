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
stdenv.mkDerivation {
  pname = "gnunet-messenger-cli";
  version = "0.3.0-unstable-2025-01-07";

  src = fetchgit {
    url = "https://git.gnunet.org/messenger-cli.git";
    rev = "ee2566bef0615c2f9937ad34c90606f6186882a8";
    hash = "sha256-ZF6vfS9a/XTnKtiaswTTV2uoBBBYuId7n9lOgPFo+/c=";
  };

  INSTALL_DIR = (placeholder "out") + "/";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

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
