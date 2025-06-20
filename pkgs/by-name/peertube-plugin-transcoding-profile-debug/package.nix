{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-transcoding-profile-debug";
  version = "0.0.5";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "077c983e32743462372c503b636814543f65845e";
    sparseCheckout = [ "peertube-plugin-transcoding-profile-debug" ];
    hash = "sha256-oa3oAKPbsg9Io1R20yhAmdNjbCIHTXN5dhmkCEpDeOY=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-plugin-transcoding-profile-debug";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  passthru.updateScript = peertube-plugin-akismet.peertubeOfficialPluginsUpdateScript;

  meta = {
    description = "Allow admins to create custom transcoding profiles using the plugin settings";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-plugin-transcoding-profile-debug";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };
})
