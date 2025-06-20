{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-hello-world";
  version = "0-unstable-2025-05-30";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "1c6f794d7a5d9c69374cb6fa1daf184258acb63a";
    sparseCheckout = [ "peertube-plugin-hello-world" ];
    hash = "sha256-U5VjoIxk/UvP+jyn8D7c75Sb2+pPxAEfJIgSPPGjlZc=";
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
