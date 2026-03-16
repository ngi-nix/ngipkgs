{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2026-03-09";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "47dc16c6c7f715d4ff267d98ef3dafa3cadf2d6f";
    hash = "sha256-SBUThRxmuqYUvOsRDXbqJcxpVoQZNM1bK3TKhvE+gQw=";
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
