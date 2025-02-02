{
  lib,
  fetchFromGitHub,
  rustPlatform,
  atomic-browser,
  nasm,
}:
let
  inherit (lib)
    licenses
    ;
in
rustPlatform.buildRustPackage rec {
  pname = "atomic-server";
  version = "0.40.0";

  src = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-server";
    rev = "v${version}";
    hash = "sha256-iZRKgRQL/+6RavFMWEugpd8+sWgXgE+itqak5BZe51s=";
  };

  cargoHash = "sha256-g8U4+e7NlVBfJSJPjr45uiJ2K2JpY0YzK8TJc4eUdoo=";

  # server/assets_tmp is the directory atomic-server's build will check for
  # compiled frontend assets to decide whether to rebuild or not
  # https://github.com/atomicdata-dev/atomic-server/blob/ba3c5959867a563d4da00bb23fd13e45e69dc5d7/server/build.rs#L22-L37
  postUnpack = ''
    mkdir -p source/server/assets_tmp
    cp -r ${atomic-browser}/* source/server/assets_tmp
  '';

  nativeBuildInputs = [ nasm ];

  doCheck = false; # TODO(jl): broken upstream

  meta = {
    description = "Reference implementation for the Atomic Data specification";
    homepage = "https://docs.atomicdata.dev";
    license = licenses.mit;
    mainProgram = "atomic-server";
  };
}
