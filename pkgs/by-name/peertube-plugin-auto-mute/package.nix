{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
}:
buildNpmPackage rec {
  pname = "peertube-plugin-auto-mute";
  version = "0.0.6";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "932c51d45ce3160ab9ba097bbede51a44d890a61";
    hash = "sha256-UGqoevqoyvWfAmumuOsdDdMIDPfaOhnjwoFXynWCgHQ=";
  };

  sourceRoot = "${src.name}/peertube-plugin-auto-mute";

  npmDepsHash = "sha256-YbFEefvSLk9jf6g6FMmCahxqA+X+FD4MCc+c6luRZq4=";

  dontNpmBuild = true;

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Auto mute accounts or instances based on public blocklists";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auto-mute";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
}
