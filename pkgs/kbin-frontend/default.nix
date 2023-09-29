{
  lib,
  kbin,
  mkYarnPackage,
  fetchYarnDeps,
  jq
}:
mkYarnPackage rec {
  inherit (kbin) version src;

  pname = "${kbin.pname}-frontend";

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-mH5E5WjEzrC+UL4yk9hwRYD1J81+hLgjHb7poPWuiFQ=";
    preBuild = ''
      cat ${./yarn-additions.lock}>> yarn.lock
    '';
  };

  #yarnFlags = ["--production" "--verbose"];

  yarnPreBuild = ''
    FROM="${kbin}/share/php/kbin"
    TO="deps/${pname}"
    for DIR in $(${lib.getExe jq} -r '.devDependencies | to_entries | .[].value | select(startswith("file:")) | ltrimstr("file:")' < ${src}/package.json)
    do
      echo "{$FROM => $TO}/$DIR"
      mkdir -pv $TO/$DIR
      cp -rv $FROM/$DIR $TO/$DIR/
      rm -fv $TO/$DIR/package.json
    done
  '';

  buildPhase = ''
    export HOME=$(mktemp -d)
    echo YARN BUILD
    yarn --offline build
  '';

  installPhase = ''
    runHook preInstall

    cd deps/${pname}
    cp dist $out

    runHook postInstall
  '';

  distPhase = "true";
}
