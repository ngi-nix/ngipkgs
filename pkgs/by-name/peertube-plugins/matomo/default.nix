{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-matomo";
  version = "0-unstable-2026-04-24";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "678a334cec1392406858f93466af875f242c4be6";
    hash = "sha256-tr8SSm8WgzY6BcTu+eqeXXAm/GZ8OaLbfhcbkmO69/4=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-matomo";

  npmDepsHash = "sha256-xPRkdEdLHVvVqcEtuDCK0V0xQxKH8RFX+UDP4RZCqpM=";

  meta = {
    description = "Matomo plugin that tracks page views on a PeerTube instance";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-matomo";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
