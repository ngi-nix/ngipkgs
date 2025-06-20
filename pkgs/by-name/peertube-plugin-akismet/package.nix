{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  unstableGitUpdater,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-akismet";
  version = "0.1.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "6d07c51ac627d76de63b093ef0cd9e20da1019cf";
    sparseCheckout = [ "peertube-plugin-akismet" ];
    hash = "sha256-W9ojtIsKo70gF9Wrpd2y1gt9T2/TDdmJ5yqWJ13+wic=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-akismet";

  npmDepsHash = "sha256-U+AQeOJI31QPeZrej6STDRtnwYJgSp86ycf4vsqSats=";

  passthru = {
    updateScript = [
      ./update.sh
      (unstableGitUpdater { })
    ];
    peertubeOfficialPluginsUpdateScript = finalAttrs.passthru.updateScript;
  };

  meta = {
    description = "Reject local comments, remote comments and registrations based on Akismet service";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-akismet";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
