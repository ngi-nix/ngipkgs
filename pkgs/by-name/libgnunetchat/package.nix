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
stdenv.mkDerivation (finalAttrs: rec {
  name = "libgnunetchat";
  version = "0.3.1";

  src = fetchgit {
    url = "https://git.gnunet.org/libgnunetchat";
    rev = "v${version}";
    hash = "sha256-8MY5QSzzLH+YUjv7nqRfiCmpFO95LzvxdvxIgHaYJP4=";
  };

  nativeBuildInputs = [meson ninja pkg-config validatePkgConfig];

  buildInputs = [check gnunet libextractor libgcrypt libsodium];

  INSTALL_DIR = (placeholder "out") + "/";

  prePatch = "mkdir -p $out/lib";

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    pkgConfigModules = ["gnunetchat"];
  };
})
