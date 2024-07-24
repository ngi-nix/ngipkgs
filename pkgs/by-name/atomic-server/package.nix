{
  lib,
  fetchFromGitHub,
  rustPlatform,
  atomic-browser,
}: let
  inherit
    (lib)
    licenses
    ;
in
  rustPlatform.buildRustPackage rec {
    pname = "atomic-server";
    version = "0.37.0";

    src = fetchFromGitHub {
      owner = "atomicdata-dev";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-+Lk2MvkTj+B+G6cNbWAbPrN5ECiyMJ4HSiiLzBLd74g=";
    };

    cargoHash = "sha256-cSv1XnuzL5PxVOTAUiyiQsMHSRUMaFDkW2/4Bt75G9o=";

    # server/assets_tmp is the directory atomic-server's build will check for
    # compiled frontend assets to decide whether to rebuild or not
    # https://github.com/atomicdata-dev/atomic-server/blob/ba3c5959867a563d4da00bb23fd13e45e69dc5d7/server/build.rs#L22-L37
    postUnpack = ''
      mkdir -p source/server/assets_tmp
      cp -r ${atomic-browser}/* source/server/assets_tmp
    '';

    doCheck = false; # TODO(jl): broken upstream

    meta = {
      description = "A Rust library to serialize, parse, store, convert, validate, edit, fetch and store Atomic Data. Powers both atomic-cli and atomic-server.";
      homepage = "docs.atomicdata.dev";
      license = licenses.mit;
    };
  }
