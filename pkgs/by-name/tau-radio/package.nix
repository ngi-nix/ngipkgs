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
  version = "0.2.3-unstable-2026-04-09";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-radio";
    rev = "750979aee4a603566edb563f0f9977d8bb32ebf3";
    hash = "sha256-1SKlZ+htlCsO7ClZDbFbKyw8v9zgV5pKDEtL57D49f8=";
  };

  cargoHash = "sha256-X1uHKYgt9ddvr/cBDW9HaHawG5uv2sU416jyL/XTPF4=";

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
