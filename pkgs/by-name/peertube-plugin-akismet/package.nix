{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  unstableGitUpdater,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-akismet";
  version = "0-unstable-2025-05-30";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "1c6f794d7a5d9c69374cb6fa1daf184258acb63a";
    sparseCheckout = [ "peertube-plugin-akismet" ];
    hash = "sha256-vFWvBxSfKg2YjKzUM0Qds7MEi9O9PFfnweOZu1Sd6KA=";
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
