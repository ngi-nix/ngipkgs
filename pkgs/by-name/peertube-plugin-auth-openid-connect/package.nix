{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-openid-connect";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    sparseCheckout = [ "peertube-plugin-auth-openid-connect" ];
    hash = "sha256-UMdiEe7lYcgkBvh50hmJgDrOdRGpMrOCHoon/tFF5VM=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-openid-connect";

  npmDepsHash = "sha256-43VpgExn5SKSb2aWuFNqL7XlGuspBiG7/JO12X+7WHk=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Add OpenID Connect support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-openid-connect";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
