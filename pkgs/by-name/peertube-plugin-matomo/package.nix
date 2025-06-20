{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-matomo";
  version = "1.0.2";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "9bd2db9033c11c650cdf1035f7eed6f4ba61cf54";
    sparseCheckout = [ "peertube-plugin-matomo" ];
    hash = "sha256-c7Wnli7L382XbfEOApPlqALkjK8Le9A9xvUOdMRq4Io=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-matomo";

  npmDepsHash = "sha256-s2vrUKMRF+VhBPAbv/RQ66UBNOBYEvi/axxJB132R9s=";

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Matomo plugin that tracks page views on a PeerTube instance";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-matomo";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
