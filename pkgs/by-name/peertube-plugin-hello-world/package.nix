{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-hello-world";
  version = "0.0.22";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "fa9005ab1bab93e41e10bb1be3dc4837bd6bbc47";
    hash = "sha256-d1DGrmRCavc1a6r3UvT7AzcLkFMJktwDKpEjgx7RJAI=";
  };

  sourceRoot = "${src.name}/peertube-plugin-hello-world";

  npmDepsHash = "sha256-Y6bq2w5ykqLMY9eDTNKL3DMkoOx+imV7OCw2Hy961Tk=";

  dontNpmBuild = true;

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Hello world PeerTube plugin example";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-hello-world";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
