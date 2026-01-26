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
  version = "0.2.101-unstable-2025-12-17";

  src = fetchFromGitHub {
    owner = "tau-org";
    repo = "tau-tower";
    rev = "566f44967f6553ab2349a7bf7b9185e2974fb3e2";
    hash = "sha256-ku5OJFnfqczmn46C4fL/GbafREYOwlDbH/Lf366fuX0=";
  };

  cargoHash = "sha256-Aere5W3S56MejbY1k/Tp3XX5NmI/ioD1XSHKRI7ai5Y=";

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
