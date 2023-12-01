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
    pname = "atomic-server";
    version = "0.34.5";

    src = fetchCrate {
      inherit pname version;
      hash = "sha256-X7G/EYhs7CBRZ+7oVKyQRk5WDyFKnQmi8aLbi/KIwgI=";
    };

    cargoHash = "sha256-mox1MdWgCgzytjqAPu1xHKWP8D5oRnXvMyqRbZXM9Pc=";

    doCheck = false; # TODO(jl): broken upstream

    meta = {
      description = "A Rust library to serialize, parse, store, convert, validate, edit, fetch and store Atomic Data. Powers both atomic-cli and atomic-server.";
      homepage = "docs.atomicdata.dev";
      license = licenses.mit;
      maintainers = with maintainers; [];
    };
  }
