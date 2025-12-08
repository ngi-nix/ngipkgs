{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-video-annotation";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    sparseCheckout = [ "peertube-plugin-video-annotation" ];
    hash = "sha256-PRcqzDyo5tJRjGGn0GYqtvGrevEpFaYchf2oK53LK3M=";
  };

  # prepare script breaks installation at peertube plugin time
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"prepare": "npm run build",' ""
  '';

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-video-annotation";

  npmDepsHash = "sha256-1/9RQZHiUtZFFycIBewGUSImGKUJdv4flZv5EaIJ02E=";

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Add a field in the video form so users can set annotation to their video";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-video-annotation";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
