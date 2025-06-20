{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-logo-framasoft";
  version = "0.0.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b4ff861a3458bd502a6b95c9005c90d786f2a74e";
    sparseCheckout = [ "peertube-plugin-logo-famasof" ];
    hash = "sha256-BwoM47xMcLHBoat0hgbO7vjzplwlDQhiMoSiRM5/Szk=";
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
