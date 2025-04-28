{
  pkgs ? import <nixpkgs> { },
}:

pkgs.stdenv.mkDerivation rec {
  pname = "xrfragment";
  version = "0.5.2";

  src = pkgs.fetchgit {
    url = "https://codeberg.org/coderofsalvation/xrfragment.git";
    rev = "v0.5.2";
    hash = "sha256-19zfnV7pVAAdft/KrXX4xbb3EgLw+M5SoEGXcKHR2kg=";
  };

  buildInputs = [
    pkgs.haxe
    pkgs.nodejs
    pkgs.yarn
    pkgs.makeWrapper
  ];
  

  buildPhase = ''
    haxe build.hxml
  '';

  installPhase = ''
    mkdir -p $out/dist
    cp -r dist/* $out/dist/
  '';

  meta = {
    description = "XR fragments: framework for spatial crossplatform fragments";
    homepage = "https://codeberg.org/coderofsalvation/xrfragment";
    license = pkgs.lib.licenses.gpl3;
  };
}