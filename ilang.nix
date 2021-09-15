{ version }:

{ stdenv, python3Packages, yosys, libresoc-verilog }:

stdenv.mkDerivation {
  pname = "libresoc.il";
  inherit version;

  src = ../src/soc/litex/florent;

  strictDeps = true;

  nativeBuildInputs = (with python3Packages; [
    c4m-jtag nmigen-soc python libresoc-ieee754fpu libresoc-openpower-isa
  ]) ++ [ yosys ];

  postPatch = ''
    patchShebangs --build .
  '';

  configurePhase = "true";

  buildPhase = ''
    runHook preBuild
    cp ${libresoc-verilog} libresoc/libresoc.v
    stat ls180soc.py
    ./ls180soc.py --build --platform=ls180sram4k --num-srams=2 --srams4k
    echo IKJIJIJIJI
    #make ls1804k
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir $out
    mv ls180.il ls180_cvt.il libresoc_cvt.il -t $out
    runHook postInstall
  '';

  fixupPhase = "true";
}
