{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2026-05-27";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "20f1b97f8c8f802318c393cebd923759a932f047";
    hash = "sha256-i9DJUHK9HA15S3J3HkhQ6f4aPqG5ffpqlRl14ZIOQ0A=";
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
