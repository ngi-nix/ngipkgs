{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-akismet";
  version = "0.1.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "6d07c51ac627d76de63b093ef0cd9e20da1019cf";
    hash = "sha256-vKA9rdfatdJqXlLqMsLL0xrNIj7A+dechwDl3QMquwE=";
  };

  sourceRoot = "${src.name}/peertube-plugin-akismet";

  npmDepsHash = "sha256-U+AQeOJI31QPeZrej6STDRtnwYJgSp86ycf4vsqSats=";

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Reject local comments, remote comments and registrations based on Akismet service";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-akismet";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
