{ version }:

{ stdenv, python2 }:

stdenv.mkDerivation {
  pname = "libresoc-pinmux";
  inherit version;

  src = ../pinmux;

  nativeBuildInputs = [ python2 ];

  configurePhase = "true";

  buildPhase = ''
    runHook preBuild
    python src/pinmux_generator.py -v -s ls180 -o ls180
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv ls180 $out
    runHook postInstall
  '';

  fixupPhase = "true";
}
