{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-video-annotation";
  version = "0.0.8";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "fee5b7eb1d8d1a51c56ea9a6b4b7d109f91b20c3";
    hash = "sha256-MWcHMAXPLAxlp+EEFs60nIAR99PBNw15bWj1/NA3ZWs=";
  };

  # prepare script breaks installation at peertube plugin time
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"prepare": "npm run build",' ""
  '';

  sourceRoot = "${src.name}/peertube-plugin-video-annotation";

  npmDepsHash = "sha256-gqEa1DwNlNR5JED0Lhhi9XFKCoJ+NhNHKioNR1A8puU=";

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Add a field in the video form so users can set annotation to their video";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-video-annotation";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
