{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-hello-world";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    sparseCheckout = [ "peertube-plugin-hello-world" ];
    hash = "sha256-AzH1rZFqEH8sovZZfJykvsEmCedEZWigQFHWHl6/PdE=";
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
