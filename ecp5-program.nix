{ version }:

{ writeShellScript, openocd, python3Packages, libresoc-ecp5, nextpnr, trellis }:

let
  pythonWithEnv = python3Packages.python.withPackages (ps: with ps; [
    requests migen libresoc-soc litex-boards litex litedram liteeth liteiclink litescope litesdcard
  ]);
in
writeShellScript "program-ecp5-libresoc" ''
  export PATH="${openocd}/bin:${pythonWithEnv}/bin:${trellis}/bin:${nextpnr}/bin:$PATH"

  dir="$(mktemp -d)"
  pushd "$dir"
  echo "$dir"

  export PYTHONPATH="${../src/soc/litex/florent}:$PYTHONPATH"

  python ${../src/soc/litex/florent/versa_ecp5.py} --sys-clk-freq=55e6 --load-from ${libresoc-ecp5}

  popd
  rm -rf "$dir"
  exit 0
''
