{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-saml2";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    hash = "sha256-mgIOklLsdJNMw7ccoyOcfpf72W2KI5BvPpCtrCmh6bQ=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-saml2";

  npmDepsHash = "sha256-Mkku+nu9WewKXzUcyaaekB3MgZ7mLeAOwGXLU5evdp8=";

  dontNpmBuild = true;

  meta = {
    description = "Add SAML2 support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-saml2";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
