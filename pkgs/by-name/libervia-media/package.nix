{
  stdenvNoCC,
  lib,
  fetchhg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "libervia-media";
  version = "0.8.0-unstable-2024-05-30";

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-media";
    rev = "731c6580247755d4e0429ffdbad4353fb976f7aa";
    hash = "sha256-NHEUvRaGe2WAocqsrl/jDtRmjwWvfbtlqyuJ5WR6ShA=";
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
      cc-by-nd-30 # linecons font, taints this as unfree
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
