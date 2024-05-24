{
  lib,
  fetchCrate,
  rustPlatform,
}: let
  inherit
    (lib)
    licenses
    ;
in
  rustPlatform.buildRustPackage rec {
    pname = "atomic-server";
    version = "0.37.0";

    src = fetchCrate {
      inherit pname version;
      hash = "sha256-/OKYac0HA9EWDQ5qNyMPITN5iUdLM9SAVmOm6PVIFOk=";
    };

    cargoHash = "sha256-LwSyK/7EEoTf1x7KGtebPxYTqH3SCjXGONNMxcmdEv0=";

    doCheck = false; # TODO(jl): broken upstream

    meta = {
      description = "A Rust library to serialize, parse, store, convert, validate, edit, fetch and store Atomic Data. Powers both atomic-cli and atomic-server.";
      homepage = "docs.atomicdata.dev";
      license = licenses.mit;
    };
  }
