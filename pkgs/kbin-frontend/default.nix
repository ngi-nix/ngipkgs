{
  lib,
  kbin,
  mkYarnPackage,
  fetchYarnDeps,

}:
mkYarnPackage rec {
  pname = "${kbin.pname}-frontend";
  name = "${kbin.pname}-frontend";

  inherit (kbin) version src;

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-mH5E5WjEzrC+UL4yk9hwRYD1J81+hLgjHb7poPWuiFQ=";
  };

  buildPhase = ''
    runHook preBuild
    export HOME=$(mktemp -d)
    ls -lHR deps/kbin-frontend/node_modules
    yarn --offline build
    runHook postBuild
  '';
}