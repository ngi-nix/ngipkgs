{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-hello-world";
  version = "0.0.22";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "fa9005ab1bab93e41e10bb1be3dc4837bd6bbc47";
    sparseCheckout = [ "peertube-plugin-hello-world" ];
    hash = "sha256-gNeOJpKYqIRVLMbgfSVXnzCD9QGOJfGcJB3IkZweTEI=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-hello-world";

  npmDepsHash = "sha256-Y6bq2w5ykqLMY9eDTNKL3DMkoOx+imV7OCw2Hy961Tk=";

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
