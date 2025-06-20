{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-openid-connect";
  version = "0.1.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "9ed56041e9a9dcb98cc610e938c7853db38cd349";
    sparseCheckout = [ "peertube-plugin-auth-openid-connect" ];
    hash = "sha256-6XQWdFJGuU8cpOZeIYwHOJJl2hRguNdS1dxS/+7Ux+g=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-openid-connect";

  npmDepsHash = "sha256-3FD9i4utzkHOjBXVPz574vttOL6VDuqM1kxtgqp8eOA=";

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
