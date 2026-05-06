{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchpatch2,

  stdenv,
  replaceVars,

  cmake,
  pkg-config,
  protobuf,

  pcre2,

  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "holo-cli";
  version = "0.5.0-unstable-2026-03-15";

  src = fetchFromGitHub {
    owner = "holo-routing";
    repo = "holo-cli";
    rev = "36fdc13323e384c086da8663f0d510b238fb6e4f";
    hash = "sha256-5Nvyh9gznMsutu3wHR6gwgKkIm115hbx4R6D/Gm1Rug=";
  };

  # cargo lock is outdated
  cargoPatches = [
    # https://github.com/holo-routing/holo-cli/pull/31
    (fetchpatch2 {
      url = "https://github.com/holo-routing/holo-cli/commit/8e282c056f7d3cc00c1f1b544659f94c150e72e9.patch?full_index=1";
      hash = "sha256-/Gw4ilFjfsMNS4em21Lkf4OmyjU0xHAKfmAXS6i320E=";
    })
  ];

  cargoHash = "sha256-77aUfXcnVQLVEKQuUdBZ4k5/3rOoe9PvGC0AlJS0UJc=";

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    pushd $cargoDepsCopy/*/libyang4-sys-*
    patch -p1 < ${
      replaceVars ./libyang4-sys.patch {
        PCRE2_INCLUDE_DIRS = "${lib.getInclude pcre2}/include";
        PCRE2_LIBRARIES = "${lib.getLib pcre2}/lib/libpcre2-8${stdenv.hostPlatform.extensions.sharedLibrary}";
      }
    }
    popd
  '';

  # Use rust nightly features
  env.RUSTC_BOOTSTRAP = 1;

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ];

  buildInputs = [
    pcre2
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Holo` Command Line Interface";
    homepage = "https://github.com/holo-routing/holo-cli";
    license = lib.licenses.mit;
    mainProgram = "holo-cli";
    maintainers = with lib.maintainers; [ themadbit ];
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
