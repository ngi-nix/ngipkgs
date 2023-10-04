{ pkgs, fetchFromGitHub, mkYarnPackage, fetchYarnDeps, ... }:

mkYarnPackage rec {
  version = "v0.34.5";

  src = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-server";
    rev = "873caf39d99f703427aa50fe32ec1aca19e4b3b0";
    hash = "sha256-mcnPv51rhfqrWGU/Gas6CJ0h0PdpRvJ2onnCw8Mccew=";
  };
  sourceRoot = "${src}/browser";

  packageJSON = "${sourceRoot}/package.json";
  # Upstream does not contain a yarn.lock
  yarnLock = ./yarn.lock;
  offlineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    hash = "sha256-GK5Ehk82VQ5ajuBTQlPwTB0aaxhjAoD2Uis8wiam7Z0=";
  };
}
