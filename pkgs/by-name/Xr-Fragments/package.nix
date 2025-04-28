{
  stdenv,
  fetchgit,
  haxe,
  nodejs,
  yarn,
  makeWrapper,
  lib,
}:

stdenv.mkDerivation rec {
  pname = "xrfragment";
  version = "0.5.2";

  src = fetchgit {
    url = "https://codeberg.org/coderofsalvation/xrfragment.git";
    rev = "v0.5.2";
    hash = "sha256-19zfnV7pVAAdft/KrXX4xbb3EgLw+M5SoEGXcKHR2kg=";
  };

  buildInputs = [
    haxe
    nodejs
    yarn
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    # build command

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out/dist
    cp -r dist/* $out/dist/
  '';

  meta = {
    description = "XR fragments: framework for spatial crossplatform fragments";
    homepage = "https://codeberg.org/coderofsalvation/xrfragment";
    license = lib.licenses.gpl3;
  };
}
