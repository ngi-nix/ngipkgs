{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  unstableGitUpdater,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-akismet";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    sparseCheckout = [ "peertube-plugin-akismet" ];
    hash = "sha256-lz9qzSpz0z7R9bwWnYKVnZHvGJhMQLHS17jP/QzXIN8=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-akismet";

  npmDepsHash = "sha256-cd/vCw2oP8lOEeg9LFj1Zh2Mmj+KKArFhtjd5G7hhTo=";

  passthru = {
    updateScript = [
      ./update.sh
      (unstableGitUpdater { })
    ];
    peertubeOfficialPluginsUpdateScript = finalAttrs.passthru.updateScript;
  };

  meta = {
    description = "Reject local comments, remote comments and registrations based on Akismet service";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-akismet";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
