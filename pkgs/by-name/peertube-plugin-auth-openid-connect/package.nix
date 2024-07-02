{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-auth-openid-connect";
  version = "0.1.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "9ed56041e9a9dcb98cc610e938c7853db38cd349";
    hash = "sha256-L9yD+amw49s+zhP4anTkXGdemitOoqJgqwzwd9PHWyw=";
  };

  sourceRoot = "${src.name}/peertube-plugin-auth-openid-connect";

  npmDepsHash = "sha256-3FD9i4utzkHOjBXVPz574vttOL6VDuqM1kxtgqp8eOA=";

  dontNpmBuild = true;

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Add OpenID Connect support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-openid-connect";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
