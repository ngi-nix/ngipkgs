{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  jack2,
  libogg,
  libopus,
  libopusenc,
  libshout,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tau-radio";
  version = "0-unstable-2025-10-13";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-radio";
    rev = "7ccc9ae83f4dc92d6eb813feb1ab7e56c5aa250a";
    hash = "sha256-bPTwuIURsiMnHqS4L6WlScGUqRyV+dyYJscTJwmWizU=";
  };

  cargoHash = "sha256-+GD0yDnihCrdpyRAbdWSGkPW+1RajYYVAmeqdNXIXFU=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libogg
    libopus
    libopusenc
    libshout
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    jack2
  ];

  # fatal error: 'opus.h' file not found
  env.NIX_CFLAGS_COMPILE = "-I${libopus.dev}/include/opus";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Web radio - Hijacks audio device using CLAP and Ogg/Opus";
    homepage = "https://github.com/tau-org/tau-radio";
    license = lib.licenses.eupl12;
    mainProgram = "tau-radio";
  };
})
