{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-privacy-remover";
  version = "0.0.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "2df3a5909536f17f143b2c391bb483e339f36c3e";
    hash = "sha256-2kcugu4uEPd/WgOe3vV6xaA1d2OcSBJy2ZkZ8gNv760=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-privacy-remover";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  # TODO: passthru.updateScript? there are no tags, versions come as file changes in subprojects

  meta = {
    description = "Remove video privacy settings of your choice";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-privacy-remover";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.unix;
  };
})
