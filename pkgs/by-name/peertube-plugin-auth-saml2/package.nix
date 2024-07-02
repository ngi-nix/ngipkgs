{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-auth-saml2";
  version = "0.0.8";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "6737d29dce5272d2abeac8a8c501ba874413e422";
    hash = "sha256-xmyVwfXPMl/8TNtDXzJ6ngrC3Y1G5gdFK+zmIEbL5Uw=";
  };

  sourceRoot = "${src.name}/peertube-plugin-auth-saml2";

  npmDepsHash = "sha256-Mkku+nu9WewKXzUcyaaekB3MgZ7mLeAOwGXLU5evdp8=";

  dontNpmBuild = true;

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Add SAML2 support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-saml2";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
