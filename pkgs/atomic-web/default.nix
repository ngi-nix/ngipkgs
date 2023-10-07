{ pkgs, fetchFromGitHub, stdenv, fetchpatch, ... }:

stdenv.mkDerivation rec {
  name = "atomic-web";
  version = "v0.34.5";

  src = fetchFromGitHub {
    owner = "atomicdata-dev";
    repo = "atomic-server";
    # FIXME(jl): note where/why for this commit hash
    rev = "873caf39d99f703427aa50fe32ec1aca19e4b3b0";
    hash = "sha256-mcnPv51rhfqrWGU/Gas6CJ0h0PdpRvJ2onnCw8Mccew=";
  };

  patches = [
    (fetchpatch {
      url =
        "https://github.com/atomicdata-dev/atomic-server/compare/develop...ngi-nix:atomic-server:workspace-versions.patch";
      hash = "sha256-r0UdQg8SAfYLilpgyqswJ9wWt/Owe6S8l7SwOlnp67cgj";
    })
  ];

  sourceRoot = "${src}/browser";

  /* packageJSON = "${sourceRoot}/package.json";
     # Upstream does not contain a yarn.lock
     yarnLock = ./yarn.lock;
     offlineCache = fetchYarnDeps {
       yarnLock = ./yarn.lock;
       hash = "sha256-GK5Ehk82VQ5ajuBTQlPwTB0aaxhjAoD2Uis8wiam7Z0=";
     };
  */
}
