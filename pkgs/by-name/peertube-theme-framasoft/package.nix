{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-framasoft";
  version = "0.0.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "e85121a9d68c9337a60198ed67e68ef520d6b50b";
    hash = "sha256-uLw4XK1I1YM/hI5gbYKJ3flyZ1GOVLarvUNa57W5bBs=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-theme-framasoft";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "PeerTube Framasoft theme";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-theme-framasoft";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
})
