{
  lib,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  ocamlPackages,
  nix-update-script,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "gendarme";
  version = "0.3-unstable-2025-11-21";

  minimalOCamlVersion = "4.13";

  src = fetchFromGitHub {
    owner = "bensmrs";
    repo = "gendarme";
    rev = "47d3dfc7762bd3b5954c212dbc1259546010aa74";
    hash = "sha256-sM9TmNCqH7Qy/HjjmPmHhX+q7t2fYMwNBuwtDx14hGQ=";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Marshalling library for OCaml";
    homepage = "https://github.com/bensmrs/gendarme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
