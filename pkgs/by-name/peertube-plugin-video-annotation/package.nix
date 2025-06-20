{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-video-annotation";
  version = "0.0.8";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "fee5b7eb1d8d1a51c56ea9a6b4b7d109f91b20c3";
    sparseCheckout = [ "peertube-plugin-video-annotation" ];
    hash = "sha256-jiGbwSaHwYfQCxe/LEywV+zEITkdWznTCo/HQyEfqvc=";
  };

  # prepare script breaks installation at peertube plugin time
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"prepare": "npm run build",' ""
  '';

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-video-annotation";

  npmDepsHash = "sha256-gqEa1DwNlNR5JED0Lhhi9XFKCoJ+NhNHKioNR1A8puU=";

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Add a field in the video form so users can set annotation to their video";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-video-annotation";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
