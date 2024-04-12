{
  lib,
  rustPlatform,
  fetchCrate,
  stdenv,
}: let
  inherit
    (lib)
    licenses
    maintainers
    ;
in
  rustPlatform.buildRustPackage rec {
    pname = "atomic-cli";
    version = "0.37.0";

    src = fetchCrate {
      inherit pname version;
      hash = "sha256-yKYqxja2XFrQmLZYiWJAJDfGDdnr4eNdAwZNKn4FseU=";
    };

    cargoHash = "sha256-a/mkZ9LFItlc3fBNCSZntbZfBJnhiFWUDIjLfBO6H74=";

    doCheck = false; # TODO(jl): broken upstream

    meta = {
      description = "CLI tool to create, store, query, validate and convert Atomic Data";
      homepage = "https://crates.io/crates/atomic-cli";
      license = licenses.mit;
      maintainers = with maintainers; [];
    };
  }
