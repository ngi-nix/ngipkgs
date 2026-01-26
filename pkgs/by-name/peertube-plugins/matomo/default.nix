{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-matomo";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    hash = "sha256-6yFcBmtKKSD6mfVAQsHDXaxb8i9t4LvN2eelQrjL7Hc=";
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
