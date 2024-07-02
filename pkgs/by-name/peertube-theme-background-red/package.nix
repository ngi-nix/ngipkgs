{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "peertube-theme-background-red";
  version = "0.0.4";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "framasoft";
    repo = "peertube/official-plugins";
    rev = "e763baddf3ad0efb215bcc8c0d3eb286d0471f21";
    hash = "sha256-50H4JU4BW/2+6xQzXkoK6Ug30FzFDRpt42mTXh1SH9o=";
  };

  sourceRoot = "${finalAttrs.src.name}/peertube-theme-background-red";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules
    cp -r $PWD $out/lib/node_modules/${finalAttrs.pname}

    runHook postInstall
  '';

  # TODO: passthru.updateScript? there are no tags, versions come as commits with changes to subdir's package.json

  meta = {
    description = "Ugly and painful example theme";
    homepage = "https://framagit.org/framasoft/peertube/official-plugins/tree/master/peertube-theme-background-red";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.unix;
  };
})
