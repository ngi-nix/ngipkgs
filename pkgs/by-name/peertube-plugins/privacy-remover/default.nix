{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-privacy-remover";
  version = "0-unstable-2026-04-24";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "678a334cec1392406858f93466af875f242c4be6";
    hash = "sha256-tr8SSm8WgzY6BcTu+eqeXXAm/GZ8OaLbfhcbkmO69/4=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-privacy-remover";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  meta = {
    description = "Remove video privacy settings of your choice";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-privacy-remover";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
