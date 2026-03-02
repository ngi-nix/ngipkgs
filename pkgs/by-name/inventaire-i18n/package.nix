{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2026-02-28";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "5b6b72dced32c579a95713d1a2ac55975c6cb106";
    hash = "sha256-M6SG5JzulWASKGoUa022riw4OZc7Cwn0K8pA6SeBYUU=";
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
