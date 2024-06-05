{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchpatch,
  gfortran,
  openblas,
  openfst,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kaldi-alphacep";
  version = "0-2023-12-20";

  src = fetchFromGitHub {
    owner = "alphacep";
    repo = "kaldi";
    rev = "2b69aed630e26fb2c700bba8c45f3bd012371c5c";
    hash = "sha256-rHDN71y0Dxv7nTYRGjPCiD9Otzf2EMKUgUJ7BisP3Rk=";
  };

  patches = [
    # https://github.com/alphacep/vosk-api/issues/1134, fix suggested in https://github.com/alphacep/kaldi/pull/4
    (fetchpatch {
      name = "0001-kaldi-alphacep-Update-OpenBLAS-to-0.3.21.patch";
      url = "https://github.com/alphacep/kaldi/commit/9f267c58b2857ba727180b0d899e1c5af1fb5686.patch";
      hash = "sha256-nNW+yi7jJQa1M04u75NFoojVJx/BWnE+DdI947ex9U0=";
    })
  ];

  postPatch = ''
    patchShebangs src/base/get_version.sh
  '';

  preConfigure = ''
    cd src
  '';

  strictDeps = true;

  buildInputs = [
    gfortran.cc.lib
    openblas
    openfst
  ];

  # Custom configure script, doesn't know prefix flag
  dontAddPrefix = true;

  configureFlags = [
    "--fst-root=${openfst}"
    "--fst-version=${openfst.passthru.baseVersion}"
    "--use-cuda=no"
    "--mathlib=OPENBLAS"
    "--openblas-root=${openblas}"
  ];

  enableParallelBuilding = true;
})
