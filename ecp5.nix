{ version }:

{ stdenv, python3Packages, yosys, libresoc-verilog, libresoc-pinmux, pkgsCross
, nextpnr, trellis }:

stdenv.mkDerivation {
  pname = "libresoc-versa-ecp5.v";
  inherit version;

  src = ../src/soc/litex/florent;

  nativeBuildInputs =
    (with python3Packages; [
    python libresoc-soc litex-boards litex litedram liteeth liteiclink litescope litesdcard
    ])
    ++ [ trellis nextpnr pkgsCross.powernv.buildPackages.gcc ];

  postPatch = ''
    patchShebangs --build .
  '';

  configurePhase = "true";

  buildPhase = ''
    runHook preBuild
    export PINMUX="$(mktemp -d)"
    ln -s ${libresoc-pinmux} "$PINMUX/ls180"
    cp ${libresoc-verilog} libresoc/libresoc.v
    ./versa_ecp5.py --sys-clk-freq=55e6 --build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv /build/florent/build/versa_ecp5/gateware/versa_ecp5.svf $out
    runHook postInstall
  '';

  fixupPhase = "true";
}
