{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-plugin-transcoding-profile-debug";
  version = "0-unstable-2025-11-20";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "b0f4f4ba5c6708ebade66dc1b17000ca640ad9e9";
    sparseCheckout = [ "peertube-plugin-transcoding-profile-debug" ];
    hash = "sha256-QGQQwAM04Vk8JZ6cp6ZOvnmGsMjvzi6Pbhk00DCVmoQ=";
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
