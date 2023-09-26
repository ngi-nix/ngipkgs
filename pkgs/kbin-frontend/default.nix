{
  lib,
  kbin,
  mkYarnPackage,
  fetchYarnDeps,
}:
mkYarnPackage rec {
  pname = "${kbin.pname}-frontend";

  inherit (kbin) version src;

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-mH5E5WjEzrC+Ui4yk9hwRYD1J81+hLgjHb7poPWuiFQ=";

    patches = [
      ../kbin/node_modules.patch
    ];
  };

  # pkgConfig.${name}.postInstall = "yarn run --offline build";

  yarnFlags = ["--verbose"];

  postBuild = ''
    cd deps/${pname}
    ls -RH
    # yarn --offline build
  '';

  installPhase = ''
    runHook preInstall

    cd deps/${pname}
    mv dist $out

    runHook postInstall
  '';

  doDist = false;
}
