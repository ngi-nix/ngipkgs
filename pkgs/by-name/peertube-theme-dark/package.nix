{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-dark";
  version = "2.5.0";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "631f784774dc5f9686bf06033d6ceb0d596ef987";
    hash = "sha256-VvtqF9et2uLxj8kGIjdaHQjxQbeNIAwz+NTPME/6Wpk=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-theme-dark";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "PeerTube dark theme";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-theme-dark";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
})
