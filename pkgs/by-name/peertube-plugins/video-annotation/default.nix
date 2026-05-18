{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-video-annotation";
  version = "0-unstable-2026-04-24";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "678a334cec1392406858f93466af875f242c4be6";
    hash = "sha256-tr8SSm8WgzY6BcTu+eqeXXAm/GZ8OaLbfhcbkmO69/4=";
  };

  # prepare script breaks installation at peertube plugin time
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"prepare": "npm run build",' ""
  '';

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-video-annotation";

  npmDepsHash = "sha256-+YymJE1vxwXJnAY2v7ppQ76fW7k23rdzvg+1E1E0Lqc=";

  meta = {
    description = "Add a field in the video form so users can set annotation to their video";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-video-annotation";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
