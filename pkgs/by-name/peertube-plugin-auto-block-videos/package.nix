{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auto-block-videos";
  version = "0.0.2";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "bf3602a782fb4605cc674aa21e1fe7dcb2693cf3";
    sparseCheckout = [ "peertube-plugin-auto-block-videos" ];
    hash = "sha256-whEVTnv2p44VWc+gzGpMwh0RRhyMNcCx1fY8QpEOCXo=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auto-block-videos";

  npmDepsHash = "sha256-inmRylbPXSJjglozVM1Xxja9eZaM+h5bv6CffiX61cA=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Auto block videos based on public blocklists";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auto-block-videos";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
