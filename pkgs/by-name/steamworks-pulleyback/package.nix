{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  arpa2common,
  arpa2cm,
  doxygen,
  graphviz,
  libuuid,
  lua,
  openssl,
  steamworks,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "steamworks-pulleyback";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "steamworks-pulleyback";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MtZDwWLcKVrNlNqhsT9tnT6qEpt2rR5S37UhHS232XI=";
  };

  nativeBuildInputs = [
    cmake
    arpa2common
    arpa2cm
  ];

  buildInputs = [
    doxygen
    graphviz
    libuuid
    lua
    openssl
    steamworks
  ];

  patches = [ ./install-dirs.patch ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_PREFIX_PATH" "${placeholder "out"}")
    (lib.cmakeFeature "PULLEY_BACKEND_DIR" "${placeholder "out"}/share/steamworks/pulleyback")
  ];
})
