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
  unstableGitUpdater,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "steamworks-pulleyback";
  version = "0.3.0-unstable-2021-08-16";

  src = fetchFromGitLab {
    owner = "arpa2";
    repo = "steamworks-pulleyback";
    rev = "0e0542ea2abfbb79fecb2ab38be9a9af1e867cc0";
    hash = "sha256-dAMaBplmknm46iqadn8JZUuG5/ZmFGLik/ejsAQlhoo=";
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

  passthru.updateScript = unstableGitUpdater { tagPrefix = "v"; };
})
