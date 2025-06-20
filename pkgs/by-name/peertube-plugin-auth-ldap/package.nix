{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
buildNpmPackage (finalAttrs: {
  pname = "peertube-plugin-auth-ldap";
  version = "0.0.12";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "fb3226e552a475f70b5ee033803274ed27a86619";
    sparseCheckout = [ "peertube-plugin-auth-ldap" ];
    hash = "sha256-bvLCCn2uSuO4ERVt5G3eTqpD50oTE4fvbyVcLV/lx20=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-auth-ldap";

  npmDepsHash = "sha256-1esTdjtbBIf3xY90xPbTZ9YmydhHO8tF430O8sIevjo=";

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
