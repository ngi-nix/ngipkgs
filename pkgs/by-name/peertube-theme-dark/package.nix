{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugins,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-dark";
  version = "0-unstable-2025-05-30";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "1c6f794d7a5d9c69374cb6fa1daf184258acb63a";
    sparseCheckout = [ "peertube-theme-dark" ];
    hash = "sha256-qICONcpP05r1BYF+GaPsp9+7CoKZcF024otOHspU2Tk=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-theme-dark";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugins.akismet.updateScript;

  meta = {
    description = "PeerTube dark theme";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-theme-dark";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
