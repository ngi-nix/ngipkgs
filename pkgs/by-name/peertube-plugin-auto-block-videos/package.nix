{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-auto-block-videos";
  version = "0.0.2";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "bf3602a782fb4605cc674aa21e1fe7dcb2693cf3";
    hash = "sha256-R+jbfubeph68aVP1Kg7QozRwrgwhXvK5QuGSZHU5iJk=";
  };

  sourceRoot = "${src.name}/peertube-plugin-auto-block-videos";

  npmDepsHash = "sha256-inmRylbPXSJjglozVM1Xxja9eZaM+h5bv6CffiX61cA=";

  dontNpmBuild = true;

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Auto block videos based on public blocklists";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auto-block-videos";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
