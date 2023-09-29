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

  yarnLock = ./yarn.lock;

  offlineCache = fetchYarnDeps {
    # yarnLock = src + "/yarn.lock";
    yarnLock = ./yarn.lock;
    hash = "sha256-wPzckzfA3apUffk7NLYX/RY9aObgbIURNd17ZlkHGeE=";
    # preBuild = ''
    #   echo ====================================================================
    #   echo Fetching other dependences
    #   mkdir $out
    #   cd $out
    #   echo vendor_symfony_stimulus-bundle_assets.lock
    #   prefetch-yarn-deps --verbose --builder ${./vendor_symfony_stimulus-bundle_assets.lock}
    #   echo vendor_symfony_ux-autocomplete_assets.lock
    #   prefetch-yarn-deps --verbose --builder ${./vendor_symfony_ux-autocomplete_assets.lock}
    #   echo vendor_symfony_ux-chartjs_assets.lock
    #   prefetch-yarn-deps --verbose --builder ${./vendor_symfony_ux-chartjs_assets.lock}
    #   echo Fetched other dependences
    #   echo ====================================================================
    # '';

    # postBuild = ''
    #   rm $out/yarn.lock
    # '';
  };

  #yarnFlags = ["--production" "--verbose"];

  yarnPreBuild = ''
    FROM="${kbin}/share/php/kbin"
    TO="deps/${pname}"

    mkdir -p $TO/vendor/friendsofsymfony/jsrouting-bundle/Resources/
    cp -rv $FROM/vendor/friendsofsymfony/jsrouting-bundle/Resources/public $TO/vendor/friendsofsymfony/jsrouting-bundle/Resources/public/

    for DIR in $(${lib.getExe jq} -r '.devDependencies | to_entries | .[].value | select(startswith("file:")) | ltrimstr("file:")' < ${src}/package.json)
    do
      echo "{$FROM => $TO}/$DIR"
      mkdir -pv $TO/$DIR
      cp -rv $FROM/$DIR $TO/$DIR/
      rm -fv $TO/$DIR/package.json
    done

    chmod -R 777 $TO/

    # pwd
    # ls -lR */yarn.lock
    # wc -l deps/kbin-frontend/yarn.lock
    # cat \
    #   ${./vendor_symfony_stimulus-bundle_assets.lock} \
    #   ${./vendor_symfony_ux-autocomplete_assets.lock} \
    #   ${./vendor_symfony_ux-chartjs_assets.lock} \
    #   >> deps/kbin-frontend/yarn.lock
    # wc -l deps/kbin-frontend/yarn.lock
  '';

  buildPhase = ''
    export HOME=$(mktemp -d)
    echo YARN BUILD
    pwd
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
