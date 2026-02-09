{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-background-red";
  version = "0-unstable-2025-12-18";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b035a3b7b109b1227c9afa6d105ea8d017bcf963";
    sparseCheckout = [ "peertube-theme-background-red" ];
    hash = "sha256-sY9FdUPBO34BXlJjfEXUxoCTBGv5hiFa2Zr2tR5FjDg=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-theme-background-red";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Ugly and painful example theme";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-theme-background-red";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
