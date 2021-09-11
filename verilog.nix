{ version }:

{ runCommand, python3Packages, libresoc-pinmux }:

let script = ''
  mkdir pinmux
  ln -s ${libresoc-pinmux} pinmux/ls180
  export PINMUX="$(realpath ./pinmux)"
  python3 -m soc.simple.issuer_verilog \
    --debug=jtag --enable-core --enable-pll \
    --enable-xics --enable-sram4x4kblock --disable-svp64 \
    $out
''; in
runCommand "libresoc.v" {
  inherit version;

  nativeBuildInputs = (with python3Packages; [
    libresoc-soc
  ]) ++ [ libresoc-pinmux ];
} script
