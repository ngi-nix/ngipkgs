{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-hello-world";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    sparseCheckout = [ "peertube-plugin-hello-world" ];
    hash = "sha256-+Xr5pPHe4r4/o+eAz+u++Zs5iwaw33OZHbbS3tJE3Ik=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-hello-world";

  npmDepsHash = "sha256-dNoVdDImF+KaOiMlW0tva4bOk2hMykHkzOZSSZWVEyw=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Hello world PeerTube plugin example";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-hello-world";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
