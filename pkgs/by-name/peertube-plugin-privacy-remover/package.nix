{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-privacy-remover";
  version = "0-unstable-2025-05-30";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "1c6f794d7a5d9c69374cb6fa1daf184258acb63a";
    sparseCheckout = [ "peertube-plugin-privacy-remover" ];
    hash = "sha256-cK1ojyhjYfOUoYfLZA7pzUtp1P1o3PXrezR+mOhS0SE=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-privacy-remover";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Remove video privacy settings of your choice";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-privacy-remover";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
