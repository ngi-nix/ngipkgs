{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2026-04-26";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "cd0e86dff4261e541cdbe97cd533e6ab1a17f6d5";
    hash = "sha256-zdpDYH3BTSTcNXLIUDZTNeQLODyJMCx+q7LGDK0krQs=";
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
