{
  stdenvNoCC,
  lib,
  fetchhg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "libervia-media";
  version = "0.8.0-unstable-2024-10-26";

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-media";
    rev = "aedac563c3f087d5cae4cb49322321906985ef45";
    hash = "sha256-n1z1xgJi5D1raTgfiHpymAgdnfJ8eKT+zcW6Z/9ciBQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/libervia/media
    cp -r * $out/share/libervia/media/

    runHook postInstall
  '';

  meta = {
    description = "Data files used by Libervia";
    homepage = "https://libervia.org";
    license = with lib.licenses; [
      ofl # fonts
      mit # fontawesome non-icons
      cc-by-40 # fontawesome icons
      gpl3Plus # split_card.sh
      cc-by-sa-30 # tarot, quiz images; toolbar, menu, misc, libervia icons; vector icons
      lgpl21Plus # crystal clear browser icons
      cc-by-sa-40 # muchoslava icons
      cc-by-30 # silk icons
      publicDomain # tango icons
      cc0 # notification sounds
      # test audio claims it's from https://musopen.org/music/14914-hungarian-rhapsody-no-4-s-2444/ and publicDomain, but site has no audio?
    ];
  };
})
