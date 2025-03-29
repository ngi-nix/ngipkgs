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
    url = "https://git.gnunet.org/libgnunetchat";
    rev = "7ac91f3ece115e576da3f04cda0a8adb5bb32176";
    hash = "sha256-9V3LVlWMRUjreeXAZWpZD2q/C8zQBu/Q4kX1CXsovuA=";
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
