{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-hello-world";
  version = "0-unstable-2026-04-24";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "678a334cec1392406858f93466af875f242c4be6";
    hash = "sha256-tr8SSm8WgzY6BcTu+eqeXXAm/GZ8OaLbfhcbkmO69/4=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-hello-world";

  npmDepsHash = "sha256-dNoVdDImF+KaOiMlW0tva4bOk2hMykHkzOZSSZWVEyw=";

  dontNpmBuild = true;

  meta = {
    description = "Hello world PeerTube plugin example";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-hello-world";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
