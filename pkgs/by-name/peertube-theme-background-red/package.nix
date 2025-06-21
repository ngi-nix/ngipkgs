{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  peertube-plugin-akismet,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-background-red";
  version = "0.0.4";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "e763baddf3ad0efb215bcc8c0d3eb286d0471f21";
    sparseCheckout = [ "peertube-theme-background-red" ];
    hash = "sha256-euc/7gEkxNmJT/W4nHZYohNQyzRsRm+JauHeNs8GD/8=";
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
