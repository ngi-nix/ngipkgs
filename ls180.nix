{ version }:

{ stdenv, python3Packages, yosys, libresoc-verilog, libresoc-pinmux, pkgsCross }:

stdenv.mkDerivation {
  pname = "libresoc-ls1804k";
  inherit version;

  src = ../src/soc/litex/florent;

  nativeBuildInputs =
    (with python3Packages; [
    python libresoc-soc litex litedram liteeth liteiclink litescope litesdcard
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
    cp ${libresoc-verilog} libresoc/libresoc.v
    ./ls180soc.py --build --platform=ls180sram4k --num-srams=2 --srams4k
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    mv build/ls180sram4k/gateware/ls180sram4k.v $out/ls180.v
    mv build/ls180sram4k/gateware/mem.init $out
    mv build/ls180sram4k/gateware/mem_1.init $out
    mv libresoc/libresoc.v $out
    mv libresoc/SPBlock_512W64B8W.v $out
    runHook postInstall
  '';

  fixupPhase = "true";
}
