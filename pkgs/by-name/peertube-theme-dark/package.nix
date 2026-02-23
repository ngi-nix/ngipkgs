{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugins,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-dark";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    sparseCheckout = [ "peertube-theme-dark" ];
    hash = "sha256-txDLxMVqgTg3/Bmxjdv5UkH3Lbm8v3/n/vpfgQkgqtE=";
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
