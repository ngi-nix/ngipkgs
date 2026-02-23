{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugins,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-framasoft";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    sparseCheckout = [ "peertube-theme-framasoft" ];
    hash = "sha256-FrH55yG7dxnYGYUORnUZ1LVPNPHVM6vEIFicahEMEuM=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-theme-framasoft";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugins.akismet.updateScript;

  meta = {
    description = "PeerTube Framasoft theme";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-theme-framasoft";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
    teams = with lib.teams; [ ngi ];
  };
})
