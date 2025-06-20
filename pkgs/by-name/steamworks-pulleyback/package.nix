{
  stdenv,
  lib,
  cmake,
  arpa2common,
  arpa2cm,
  steamworks,
  lua,
  doxygen,
  graphviz,
  libuuid,
  fetchFromGitLab,
}:
stdenv.mkDerivation rec {
  pname = "steamworks-pulleyback";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "steamworks-pulleyback";
    rev = "v${version}";
    hash = "sha256-MtZDwWLcKVrNlNqhsT9tnT6qEpt2rR5S37UhHS232XI=";
  };

  nativeBuildInputs = [
    cmake
    arpa2common
    arpa2cm
  ];

  buildInputs = [
    steamworks
    lua
    doxygen
    graphviz
    libuuid
  ];

  patches = [ ./install-dirs.patch ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_PREFIX_PATH" "${placeholder "out"}")
    (lib.cmakeFeature "PULLEY_BACKEND_DIR" "${placeholder "out"}/share/steamworks/pulleyback")
  ];
}
