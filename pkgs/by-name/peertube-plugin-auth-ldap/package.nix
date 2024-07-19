{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-auth-ldap";
  version = "0.0.12";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "fb3226e552a475f70b5ee033803274ed27a86619";
    hash = "sha256-VzypXOf05nigevG9E8AIISEbR7XI+TExyJMv1MDMfOY=";
  };

  sourceRoot = "${src.name}/peertube-plugin-auth-ldap";

  npmDepsHash = "sha256-1esTdjtbBIf3xY90xPbTZ9YmydhHO8tF430O8sIevjo=";

  dontNpmBuild = true;

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Add LDAP support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-ldap";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
