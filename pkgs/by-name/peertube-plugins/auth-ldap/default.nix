{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-ldap";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    hash = "sha256-6yFcBmtKKSD6mfVAQsHDXaxb8i9t4LvN2eelQrjL7Hc=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-ldap";

  npmDepsHash = "sha256-Q3HDMv8Suac3y8yP+obnnMuhKS6gteHfmVZjfzCkUBY=";

  dontNpmBuild = true;

  meta = {
    description = "Add LDAP support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-ldap";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
