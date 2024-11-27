{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-matomo";
  version = "1.0.2";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "9bd2db9033c11c650cdf1035f7eed6f4ba61cf54";
    hash = "sha256-EUocSJLi2s9VXddRIffG1Aj8/1AlegwP+76IbowhoOo=";
  };

  sourceRoot = "${src.name}/peertube-plugin-matomo";

  npmDepsHash = "sha256-s2vrUKMRF+VhBPAbv/RQ66UBNOBYEvi/axxJB132R9s=";

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Matomo plugin that tracks page views on a PeerTube instance";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-matomo";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
