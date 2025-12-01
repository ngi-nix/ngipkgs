{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auto-block-videos";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    sparseCheckout = [ "peertube-plugin-auto-block-videos" ];
    hash = "sha256-fe6P6jmJMRL0Tzq4LB57TPAoFQTQYdrUG26mYUBjOqk=";
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
