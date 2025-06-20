{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-logo-framasoft";
  version = "0-unstable-2025-05-30";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "1c6f794d7a5d9c69374cb6fa1daf184258acb63a";
    sparseCheckout = [ "peertube-plugin-logo-famasof" ];
    hash = "sha256-jn4jWFREfcXXwxLMdwZ7Jfjl5ZM//nE18YuI2EAx/0c=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-logo-framasoft";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Framasoft logo on PeerTube";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-logo-framasoft";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
