{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  unstableGitUpdater,
  pkg-config,
  alsa-lib,
  jack2,
  libogg,
  libopus,
  libopusenc,
  libshout,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tau-radio";
  version = "0-unstable-2025-09-30";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-radio";
    rev = "0bf4db0c1894ef7956e5b13b7797e97ff3d67210";
    hash = "sha256-kT0rxYApVAp+Ue3W7KXhywDlh66T0v5UjUmYWwo57wM=";
  };

  cargoHash = "sha256-1bALBwxJh2gJcqfuIeiGwB3paM98hjYcvPTxcWz8mo8=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libshout
    libopusenc
    libopus
    libogg
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    jack2
    alsa-lib
  ];

  # fatal error: 'opus.h' file not found
  env.NIX_CFLAGS_COMPILE = "-I${libopus.dev}/include/opus";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Web radio - Hijacks audio device using CLAP and Ogg/Opus";
    homepage = "https://github.com/tau-org/tau-radio";
    license = lib.licenses.eupl12;
    mainProgram = "tau-radio";
  };
})
