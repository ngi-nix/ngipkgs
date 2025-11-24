{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rest-api";
  version = "1.12.0";

  src = fetchurl {
    url = "https://www.igniterealtime.org/projects/openfire/plugins/${finalAttrs.version}/restAPI.jar";
    hash = "sha256-oc1bcUN+XWzQu/aimFN7qnjxmlDyEE9MG7lFlaNQzPY=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src -t $out/opt/plugins

    runHook postInstall
  '';
})
