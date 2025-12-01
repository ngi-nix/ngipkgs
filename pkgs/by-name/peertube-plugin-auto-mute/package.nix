{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auto-mute";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    sparseCheckout = [ "peertube-plugin-auto-mute" ];
    hash = "sha256-YnT76MDy3IKGhwWhV39YV8xT/WJo6c8lDuRtU6d7gJ4=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auto-mute";

  npmDepsHash = "sha256-QWrtnZTV10FWFaL1DEIomJgzMqwjQnOZYSfBZZuVGH8=";

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
