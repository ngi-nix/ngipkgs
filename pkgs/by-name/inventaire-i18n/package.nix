{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "inventaire-i18n";
  version = "0-unstable-2025-10-20";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-i18n";
    rev = "ff65e4b40549955decdcc5c6913daa1672242901";
    hash = "sha256-N9/zIul/rzd/vvTJmN1cXIXM9cgvDKlishmw0kH+z34=";
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
