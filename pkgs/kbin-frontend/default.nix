{
  lib,
  kbin,
  mkYarnPackage,
  fetchYarnDeps,
  jq,
}:
mkYarnPackage rec {
  inherit (kbin) version src;

  pname = "${kbin.pname}-frontend";

  offlineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-++uJtTKaXJR7K8H+nk19QyX0xiIQB+4v6Rhtvf9cz4U=";
    preBuild = ''
      echo ====================================================================
      echo Fetching other dependences
      mkdir $out
      cd $out
      echo vendor_symfony_stimulus-bundle_assets.lock
      prefetch-yarn-deps --verbose --builder ${./vendor_symfony_stimulus-bundle_assets.lock}
      echo vendor_symfony_ux-autocomplete_assets.lock
      prefetch-yarn-deps --verbose --builder ${./vendor_symfony_ux-autocomplete_assets.lock}
      echo vendor_symfony_ux-chartjs_assets.lock
      prefetch-yarn-deps --verbose --builder ${./vendor_symfony_ux-chartjs_assets.lock}
      echo Fetched other dependences
      echo ====================================================================
    '';

    postBuild = ''
      rm $out/yarn.lock
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
