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

stdenv.mkDerivation (finalAttrs: {
  pname = "gnunet-messenger-cli";
  version = "0.3.1";

  src = fetchgit {
    url = "https://git.gnunet.org/messenger-cli.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8Iby3IZXEZJ1dqVV62xDzXx/qq7JKhVtn6ZLb697ZSw=";
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
})
