{ version }:

{ stdenv, python3Packages, yosys, libresoc-pre-litex, libresoc-pinmux, pkgsCross }:

stdenv.mkDerivation {
  pname = "libresoc-versa-ecp5";
  inherit version;

  src = ../src/soc/litex/florent;

  nativeBuildInputs =
    (with python3Packages; [
    python libresoc-soc litex-boards litex litedram liteeth liteiclink litescope litesdcard
    ])
    ++ [ pkgsCross.powernv.buildPackages.gcc ];

  postPatch = ''
    patchShebangs --build .
  '';

  configurePhase = "true";

  buildPhase = ''
    runHook preBuild
    export PINMUX="$(mktemp -d)"
    ln -s ${libresoc-pinmux} "$PINMUX/ls180"
    cp ${libresoc-pre-litex} libresoc/libresoc.v
    ./versa_ecp5.py --sys-clk-freq=55e6 --build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  fixupPhase = "true";
}
