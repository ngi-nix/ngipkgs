{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auto-block-videos";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    hash = "sha256-6yFcBmtKKSD6mfVAQsHDXaxb8i9t4LvN2eelQrjL7Hc=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auto-block-videos";

  npmDepsHash = "sha256-inmRylbPXSJjglozVM1Xxja9eZaM+h5bv6CffiX61cA=";

  dontNpmBuild = true;

  meta = {
    description = "Auto block videos based on public blocklists";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auto-block-videos";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
