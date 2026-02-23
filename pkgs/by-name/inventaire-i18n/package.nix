{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2026-02-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "62a9c66898c4fa2e2e062619d6d26680b8d07d7c";
    hash = "sha256-A0D8Q5A4jzU9Xl9y2rse8Pf2q4ZcJRRKO2kzcGHy6kQ=";
  };

  npmDepsHash = "sha256-67PiiCrVUtqJklzxawUjNQ3uXd+TwUmDL+/DOWFl7G4=";

  postPatch = ''
    patchShebangs scripts
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Repository hosting inventaire i18n strings and scripts";
    homepage = "https://codeberg.org/inventaire/inventaire-i18n";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
