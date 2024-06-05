{
  stdenv,
  lib,
  callPackage,
  fetchFromGitHub,
  cmake,
}:

let
  openfst-alphacep = callPackage ./openfst.nix { };
  kaldi = callPackage ./kaldi.nix {
    openfst = openfst-alphacep;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vosk";
  version = "0.3.50";

  src = fetchFromGitHub {
    owner = "alphacep";
    repo = "vosk-api";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-E0Xl+TbI06ArHSk1t6DsXLUlfMQZGKQMTp7smGxgp2Y=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    kaldi
  ];
})
