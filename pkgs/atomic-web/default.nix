{ pkgs, fetchFromGitHub, mkYarnPackage, fetchYarnDeps, fetchpatch, ... }:
let
  source = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-server";
    # FIXME(jl): note where/why for this commit hash
    rev = "873caf39d99f703427aa50fe32ec1aca19e4b3b0";
    hash = "sha256-mcnPv51rhfqrWGU/Gas6CJ0h0PdpRvJ2onnCw8Mccew=";
  };
in
mkYarnPackage rec {
  name = "atomic-web";
  version = "v0.34.5";
  src = "${source}/browser";

  patches = [
    ./workspaces.patch
  ];

  installPhase = "";
  distPhase = "";

   packageJSON = "${source}/browser/package.json";
   # Upstream does not contain a yarn.lock
   yarnLock = ./yarn.lock;
   offlineCache = fetchYarnDeps {
     yarnLock = ./yarn.lock;
     hash = "sha256-GK5Ehk82VQ5ajuBTQlPwTB0aaxhjAoD2Uis8wiam7Z0=";
   };
}
