{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-ldap";
  version = "0-unstable-2025-05-30";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "1c6f794d7a5d9c69374cb6fa1daf184258acb63a";
    sparseCheckout = [ "peertube-plugin-auth-ldap" ];
    hash = "sha256-kyQeVRNRgEVh74fjFvwto9dDbliurQhRTlb0+gYYf1Q=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-ldap";

  npmDepsHash = "sha256-Q3HDMv8Suac3y8yP+obnnMuhKS6gteHfmVZjfzCkUBY=";

  dontNpmBuild = true;

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Add LDAP support to login form in PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-auth-ldap";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
