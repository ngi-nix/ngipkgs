{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-transcoding-custom-quality";
  version = "0.1.0";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "9731357f9fb68c48df9cdc3f51fe3dafbecf3bf6";
    hash = "sha256-diklMd0S6wUsQKunQYLGzrIJqIfAfDzBTZy6aUiu584=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-transcoding-custom-quality";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Set a custom quality for transcoding";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-transcoding-custom-quality";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
})
