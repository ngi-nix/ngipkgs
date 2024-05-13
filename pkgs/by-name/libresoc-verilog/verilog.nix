{
  runCommand,
  pinmux,
  libresoc-nmigen,
}:
runCommand "libresoc.v" {
  version = "unstable-2024-03-31";

  nativeBuildInputs = [
    libresoc-nmigen
    pinmux
  ];
} ''
  mkdir pinmux
  ln -s ${pinmux} pinmux/ls180
  export PINMUX="$(realpath ./pinmux)"
  python3.9 -m soc.simple.issuer_verilog \
    --debug=jtag --enable-core --enable-pll \
    --enable-xics --enable-sram4x4kblock --disable-svp64 \
    $out
''
