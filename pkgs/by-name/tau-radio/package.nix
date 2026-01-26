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
  version = "0.2.101-unstable-2025-12-17";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-radio";
    rev = "1847e4b4d91e941c19072752ed3afa95f2941a68";
    hash = "sha256-DW37p4FCK78Yk4KUtOcSfgjZGXhRytQA3/fR+ZkijxQ=";
  };

  cargoHash = "sha256-zqucj1iNsUdA06D+tDyYkevF/gio31JmcP00bk5PC18=";

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
