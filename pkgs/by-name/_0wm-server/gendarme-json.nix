{
  lib,
  writableTmpDirAsHomeHook,
  ocamlPackages,
  gendarme,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "gendarme-json";
  inherit (gendarme) version src;

  minimalOCamlVersion = "4.13";

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  meta = {
    description = "Metapackage for JSON marshalling using Gendarme";
    homepage = "https://github.com/bensmrs/gendarme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
