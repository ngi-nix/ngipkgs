{
  stdenv,
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

  configurePhase = ''
    mkdir -p build
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out \
             -DCMAKE_PREFIX_PATH=$out \
             -DPULLEY_BACKEND_DIR=$out/share/steamworks/pulleyback/
  '';
}
