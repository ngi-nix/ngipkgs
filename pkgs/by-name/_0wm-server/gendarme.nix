{
  lib,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  ocamlPackages,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "gendarme";
  version = "0.3-unstable-2025-09-23";

  minimalOCamlVersion = "4.13";

  src = fetchFromGitHub {
    owner = "bensmrs";
    repo = "gendarme";
    rev = "eccdfd253ff02a854fd4d1f1bcc78cee34bcd491";
    hash = "sha256-+5CWsQVNc+DT6zJYXhijNf1HGNjFdswkJQ6/dlpIK8Y=";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  meta = {
    description = "Marshalling library for OCaml";
    homepage = "https://github.com/bensmrs/gendarme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
