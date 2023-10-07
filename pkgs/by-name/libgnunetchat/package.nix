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
  version = "0.1.3";

  src = fetchgit {
    url = "https://git.gnunet.org/libgnunetchat";
    rev = "v${version}";
    hash = "sha256-0sp/MfM6CBOI60k8tZscFamc5Y2cnyRaAds6bSXhm3w=";
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
