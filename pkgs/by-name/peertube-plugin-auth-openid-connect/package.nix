{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-openid-connect";
  version = "0-unstable-2025-05-30";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "1c6f794d7a5d9c69374cb6fa1daf184258acb63a";
    sparseCheckout = [ "peertube-plugin-auth-openid-connect" ];
    hash = "sha256-vc1ZOO1hAmTD2NE4P7WELZjDTP7+CwJk7yMCXeuRn0E=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-openid-connect";

  npmDepsHash = "sha256-NXCjLPJvFZ05b3gHnhnGF58ULgfL23+r6b0IaMeIw60=";

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
