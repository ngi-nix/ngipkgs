{
  stdenv,
  fetchgit,
  # Build Tools:
  meson,
  ninja,
  pkg-config,
  # Validation:
  validatePkgConfig,
  testers,
  # Dependencies:
  check,
  gnunet,
  libsodium,
  libgcrypt,
  libextractor,
}:
# From https://github.com/ngi-nix/gnunet-messenger-cli/blob/main/flake.nix
stdenv.mkDerivation (finalAttrs: {
  name = "libgnunetchat";
  version = "0.5.3";

  src = fetchgit {
    url = "https://git.gnunet.org/libgnunetchat.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DhXPYa8ya9cEbwa4btQTrpjfoTGhzBInWXXH4gmDAQw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    validatePkgConfig
  ];

  buildInputs = [
    check
    gnunet
    libextractor
    libgcrypt
    libsodium
  ];

  INSTALL_DIR = (placeholder "out") + "/";

  prePatch = "mkdir -p $out/lib";

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    pkgConfigModules = [ "gnunetchat" ];
  };
})
