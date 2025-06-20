{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auto-mute";
  version = "0.0.6";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "932c51d45ce3160ab9ba097bbede51a44d890a61";
    sparseCheckout = [ "peertube-plugin-auto-mute" ];
    hash = "sha256-OOIUXs09Gx5WkXE8W8BpIwwpSxqDp0ifJh5PsA4Eoko=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auto-mute";

  npmDepsHash = "sha256-YbFEefvSLk9jf6g6FMmCahxqA+X+FD4MCc+c6luRZq4=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Auto mute accounts or instances based on public blocklists";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auto-mute";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
