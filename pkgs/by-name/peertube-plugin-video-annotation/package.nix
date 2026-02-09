{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-video-annotation";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    sparseCheckout = [ "peertube-plugin-video-annotation" ];
    hash = "sha256-laBs12OGvLQj70qvLC40RrXzhsmLfJyyPbkeZub4Fgs=";
  };

  # prepare script breaks installation at peertube plugin time
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"prepare": "npm run build",' ""
  '';

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-video-annotation";

  npmDepsHash = "sha256-+YymJE1vxwXJnAY2v7ppQ76fW7k23rdzvg+1E1E0Lqc=";

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Add a field in the video form so users can set annotation to their video";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-video-annotation";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
