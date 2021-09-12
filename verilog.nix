{ version }:

{ stdenv, python3Packages }:

stdenv.mkDerivation {
  pname = "libresoc.v";
  inherit version;

  src = ../.;

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [
    c4m-jtag nmigen-soc python libresoc-ieee754fpu libresoc-openpower-isa
  ];

  configurePhase = "true";

  buildPhase = ''
    runHook preBuild
    cd src
    export PYTHONPATH="$PWD:$PYTHONPATH"
    python3 soc/simple/issuer_verilog.py \
      --debug=jtag --enable-core --enable-pll \
      --enable-xics --enable-sram4x4kblock --disable-svp64 \
      libresoc.v
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv libresoc.v $out
    runHook postInstall
  '';

  fixupPhase = "true";
}
