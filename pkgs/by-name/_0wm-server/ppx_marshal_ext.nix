{
  lib,
  writableTmpDirAsHomeHook,
  ocamlPackages,
  gendarme,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "ppx_marshal_ext";
  inherit (gendarme) version src;

  minimalOCamlVersion = "4.13";

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  propagatedBuildInputs = with ocamlPackages; [
    gendarme
    ppxlib
  ];

  meta = {
    description = "Preprocessor extension to simplify writing Gendarme encoders";
    homepage = "https://github.com/bensmrs/gendarme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
