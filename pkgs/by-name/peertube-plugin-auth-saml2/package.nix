{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-saml2";
  version = "0.0.8";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "6737d29dce5272d2abeac8a8c501ba874413e422";
    sparseCheckout = [ "peertube-plugin-auth-saml2" ];
    hash = "sha256-qLTL+FoXHpXwNGwc77v4S04zqp8EcfElkw3+ZW1k2CM=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-saml2";

  npmDepsHash = "sha256-Mkku+nu9WewKXzUcyaaekB3MgZ7mLeAOwGXLU5evdp8=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Add SAML2 support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-saml2";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
