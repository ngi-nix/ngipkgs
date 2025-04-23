{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  protobuf,
  pcre2,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "holo-cli";
  version = "0.4.0-unstable-2025-04-01";

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  src = fetchFromGitHub {
    owner = "holo-routing";
    repo = "holo-cli";
    rev = "ebec1a13a3ddf540bca32fa928ac803a538fec8d";
    hash = "sha256-AQOGq1IUt6oXadzCtqxt8YGX0Va0pby5pEp2xdBuPeI=";
  };

  # Use rust nightly features
  RUSTC_BOOTSTRAP = 1;

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ];
  buildInputs = [
    pcre2
  ];

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "Holo` Command Line Interface";
    homepage = "https://github.com/holo-routing/holo-cli";
    license = lib.licenses.mit;
    mainProgram = "holo-cli";
  };
})
