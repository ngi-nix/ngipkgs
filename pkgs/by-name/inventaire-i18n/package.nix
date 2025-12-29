{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2025-12-16";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "fde63c818f6f3e223c382359547699a354c2226d";
    hash = "sha256-aALXgiHk5E0YN49eiwDjj6fNCvSI7hVwQy+VDZJ/aag=";
  };

  npmDepsHash = "sha256-hJ9L9X53n44Iz0lKX2NspMLtQbQA0nRgJvYZc5+xNuA=";

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
