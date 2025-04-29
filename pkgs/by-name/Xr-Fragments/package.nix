{
  lib,
  stdenv,
  fetchgit,
  nodejs,
  yarn,
  haxe,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xrfragment";
  version = "0.5.2";

  src = fetchgit {
    url = "https://codeberg.org/coderofsalvation/xrfragment.git";
    rev = "v0.5.2";
    hash = "sha256-19zfnV7pVAAdft/KrXX4xbb3EgLw+M5SoEGXcKHR2kg=";
  };

  nativeBuildInputs = [
    haxe
    nodejs
    yarn
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
     haxe build.hxml
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/dist
    cp -r dist/* $out/dist/

    runHook postInstall
  '';

  meta = {
    description = "XR fragments: framework for spatial crossplatform fragments";
    homepage = "https://codeberg.org/coderofsalvation/xrfragment";
    license = lib.licenses.gpl3;
  };
})
