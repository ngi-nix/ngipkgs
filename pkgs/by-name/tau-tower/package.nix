{
  lib,
  rustPlatform,
  fetchFromGitHub,
  perl,
  pkg-config,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tau-tower";
  version = "0-unstable-2025-09-30";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-tower";
    rev = "61ac7df67ed365d5e3edef4c3f48d6b20371a291";
    hash = "sha256-g3pMh77QKDyrt4qwmY0pRuSg/P/Sju84g0MZtclT7ng=";
  };

  cargoHash = "sha256-kjJ2wPPs/BQviztnvEoe+Ujb4v9UyhCYX7uOTrEfhqg=";

  nativeBuildInputs = [
    perl
    pkg-config
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Webradio server - broadcasts audio source to clients";
    homepage = "https://github.com/tau-org/tau-tower";
    license = lib.licenses.eupl12;
    mainProgram = "tau-tower";
  };
})
