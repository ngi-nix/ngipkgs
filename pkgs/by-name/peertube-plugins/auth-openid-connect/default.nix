{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-openid-connect";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    hash = "sha256-6yFcBmtKKSD6mfVAQsHDXaxb8i9t4LvN2eelQrjL7Hc=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-openid-connect";

  npmDepsHash = "sha256-43VpgExn5SKSb2aWuFNqL7XlGuspBiG7/JO12X+7WHk=";

  dontNpmBuild = true;

  meta = {
    description = "Add OpenID Connect support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-openid-connect";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
