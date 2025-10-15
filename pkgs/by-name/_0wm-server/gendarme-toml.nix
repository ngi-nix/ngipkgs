{
  lib,
  writableTmpDirAsHomeHook,
  ocamlPackages,
  gendarme,
  ppx_marshal_ext,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "gendarme-toml";
  inherit (gendarme) version src;

  minimalOCamlVersion = "4.13";

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  buildInputs = with ocamlPackages; [
    ppx_marshal_ext
    toml
  ];

  meta = {
    description = "Marshal OCaml data structures to TOML";
    homepage = "https://github.com/bensmrs/gendarme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
