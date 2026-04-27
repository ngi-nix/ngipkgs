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
  version = "0.2.3-unstable-2026-04-10";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-tower";
    rev = "4061e0518d7a461a061fdc0a13fc4fe332f1c528";
    hash = "sha256-/mfFin1HjHsJ8IHPSsLLYaq1432ZFtzg8gGTPGUmhLw=";
  };

  cargoHash = "sha256-Qv97FTiccfQSBI2OBfl31p3oF/JCL/+UXkK+owuByDY=";

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
