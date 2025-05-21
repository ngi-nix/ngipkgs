{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  fetchFromGitHub,
  gitUpdater,
  curl,
  inventaire-unwrapped,
  inventaire-i18n,
  nix,
  nodejs,
  replaceVars,
  runCommandNoCC,
  writeShellApplication,
  _experimental-update-script-combinators,

  # In case users want to override these with different ones
  sparql-queries ? runCommandNoCC "sparql-queries-unpacked" { } ''
    cp -r --no-preserve=mode ${./sparql-queries} $out
    for archive in $out/*.gz; do
      gunzip "$archive"
    done
  '',
}:

let
  visual-viewport = fetchFromGitHub {
    owner = "WICG";
    repo = "visual-viewport";
    rev = "44deaba64b1c2c474bf5a4ece07eefa93b2fb028";
    hash = "sha256-uMNqmMBDmz2zmPYjpVuQeCw4DsSm8DYhC33jOpMQj+w=";
  };

  # scripts/build_i18n, with all the manual i18n cloning & building ripped out
  copyI18nDataScript = writeShellApplication {
    name = "copy_i18n_data";
    text = ''
      echo "[Nix] Copying already-built data from ${inventaire-i18n}"

      rm -rf ./public/i18n
      cp -rv --no-preserve=all ${inventaire-i18n}/lib/node_modules/inventaire-i18n/dist/client ./public/i18n

      mkdir -vp ./app/assets/js
      rm -f ./app/assets/js/languages_data.*
      cp -v --no-preserve=all ${inventaire-i18n}/lib/node_modules/inventaire-i18n/dist/languages_data.ts ./app/assets/js/

      # Upstream script doesn't copy this, but webpack/babel is unhappy with parsing the typescript one if this is missing
      cp -v --no-preserve=all ${inventaire-i18n}/lib/node_modules/inventaire-i18n/dist/languages_data.js ./app/assets/js/
    '';
  };
in
buildNpmPackage rec {
  pname = "inventaire-client";
  version = "4.0.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-client";
    tag = "v${version}";
    hash = "sha256-5v6JNqinlaiyDFidn6j7zaXdIoCaf8L6qHoa6qhC5Uk=";
  };

  patches = [
    (replaceVars ./9901-Use-saved-query-results.patch {
      sparqlQueries = sparql-queries;
    })
  ];

  npmDepsHash = "sha256-B690tSp08e5xasNpA+dMKQXnbPNYga67ecazvxeRJxQ=";

  postPatch = ''
    patchShebangs scripts

    # inventaire (server-side) is not at a directory above us during build, patch in path to our prebuilt one
    substituteInPlace package.json tsconfig.base.json \
      --replace-fail '"../server/' '"${inventaire-unwrapped}/lib/node_modules/inventaire/dist/server/' \

    # TypeError: wdk.simplifySparqlResults is not a function
    # items is a list of objects, so id are objects. This generates [object Object] URLs otherwise.
    substituteInPlace scripts/sitemaps/generate_sitemaps.js \
      --replace-fail 'wdk.simplifySparqlResults' 'wdk.simplify.sparqlResults' \
      --replace-fail 'entity/wd:''${id}' 'entity/wd:''${id.item}'

    # Don't do git things
    # Don't build in configurePhase
    # Don't fetch a file, copy prefetched copy instead
    # Don't nuke node_modules cache
    substituteInPlace scripts/postinstall \
      --replace-fail 'git config' '# git config' \
      --replace-fail 'npm run build' 'echo "[Nix] Building later"' \
      --replace-fail \
        'curl -sk https://raw.githubusercontent.com/WICG/visual-viewport/44deaba/polyfill/visualViewport.js >> ./vendor/visual_viewport_polyfill.js' \
        'cat ${visual-viewport}/polyfill/visualViewport.js >> ./vendor/visual_viewport_polyfill.js' \
      --replace-fail 'ln -s ../scripts/githooks' '# ln -s ../scripts/githooks' \
      --replace-fail 'rm -rf ./node_modules/.cache' '# rm -rf ./node_modules/.cache' \

    # Don't check environment. We are not matching what it wants, and we don't want to deal with the interactive part of that script
    # Don't clone & build inventaire-i18n, copy things together from our prebuilt one instead
    # Don't show webpack progress bar, messes with output
    # Don't use current date, use SOURCE_DATE_EPOCH
    # Don't query for git info, use what we have from src instead
    substituteInPlace scripts/build \
      --replace-fail './scripts/check_build_environment.sh' 'echo "[Nix] Not running: ./scripts/check_build_environment.sh"' \
      --replace-fail './scripts/build_i18n' '${lib.getExe copyI18nDataScript}' \
      --replace-fail 'webpack --config ./bundle/webpack.config.prod.cjs --progress' 'webpack --config ./bundle/webpack.config.prod.cjs' \
      --replace-fail 'date -Ins' 'date -d "@$SOURCE_DATE_EPOCH" -Ins' \
      --replace-fail '$(git rev-parse --short HEAD)' '"${
        if src.tag != null then src.tag else src.rev
      }"' \
  '';

  # "Your cache folder contains root-owned files" error from NPM
  makeCacheWritable = true;

  # Actually error out when this failed
  postBuild = ''
    if [ ! -e ./public/sitemaps/sitemapindex.xml ]; then
      echo "Sitemaps generation likely failed!"
      exit 1
    fi
  '';

  # These get produced/modified during the build, but not installed (fully)
  postInstall = ''
    cp -r app public vendor $out/lib/node_modules/inventaire-client/
  '';

  passthru = rec {
    updateSourceScript = gitUpdater {
      rev-prefix = "v";
    };
    updateQueriesScript = writeShellApplication {
      name = "inventaire-client-sparql-queries-update-script";
      runtimeInputs = [
        curl
        nix
        nodejs
      ];
      runtimeEnv = {
        storeDir = builtins.storeDir;
        dumpUrlsJson = ./dump-urls-json.js;
      };
      text = lib.strings.readFile ./update-sparql-queries.sh;
    };
    updateScript = _experimental-update-script-combinators.sequence [
      updateSourceScript.command
      updateQueriesScript
    ];
  };

  meta = {
    description = "A libre collaborative resources mapper powered by open-knowledge (client-side)";
    homepage = "https://inventaire.io";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
