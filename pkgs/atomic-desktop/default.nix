{ fetchFromGitHub, rustPlatform, stdenv, lib, pkg-config, glib, ... }:

rustPlatform.buildRustPackage rec {
  pname = "atomic-server-tauri";
  version = "0.34.5";

  src = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-server";
    rev = "v${version}";
    hash = "sha256-rqucTVvlXe9CXPsZ2cNzyDK9onXw/H96PzWpTR7Fdl4=";
  };

  sourceRoot = "${src.name}/desktop";

  nativeBuildInputs = [
    pkg-config
    glib # FIXME(jl): is this a runtime dep?
  ];

  cargoHash = "sha256-5N6P2oHw/sTGUrLdw2bCw8mNHy5OxFPUhUoQEWkwkm4=";

  meta = with lib; {
    description = "";
    homepage = "";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
