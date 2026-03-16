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
  version = "0.2.2-beta-unstable-2026-03-14";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-tower";
    rev = "26908437b568c80fc470934948067341e581d43e";
    hash = "sha256-qaui9xWNWuh669kWyTnLGqtuDIKFs4K5Iv3Tti6Befk=";
  };

  cargoHash = "sha256-5BAL5A78LIgr5G50aU1TXl19qkKiUPPVJn/QogfRMKI=";

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
