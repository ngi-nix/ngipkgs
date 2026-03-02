{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-matomo";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    hash = "sha256-mgIOklLsdJNMw7ccoyOcfpf72W2KI5BvPpCtrCmh6bQ=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-matomo";

  npmDepsHash = "sha256-s2vrUKMRF+VhBPAbv/RQ66UBNOBYEvi/axxJB132R9s=";

  meta = {
    description = "Matomo plugin that tracks page views on a PeerTube instance";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-matomo";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
