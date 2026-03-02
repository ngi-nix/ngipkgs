{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-akismet";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    hash = "sha256-mgIOklLsdJNMw7ccoyOcfpf72W2KI5BvPpCtrCmh6bQ=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-akismet";

  npmDepsHash = "sha256-cd/vCw2oP8lOEeg9LFj1Zh2Mmj+KKArFhtjd5G7hhTo=";

  meta = {
    description = "Reject local comments, remote comments and registrations based on Akismet service";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-akismet";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
