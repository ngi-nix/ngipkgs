{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-framasoft";
  version = "0.0.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "e85121a9d68c9337a60198ed67e68ef520d6b50b";
    sparseCheckout = [ "peertube-theme-framasoft" ];
    hash = "sha256-3HfAT1kXtKRy+iFfPQXPrsdwIzbx8eAPTkThU48xbfE=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-theme-framasoft";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "PeerTube Framasoft theme";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-theme-framasoft";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
