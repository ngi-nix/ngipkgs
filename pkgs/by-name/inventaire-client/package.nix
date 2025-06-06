{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  fetchFromGitHub,
  fetchpatch,
  inventaire-unwrapped,
  inventaire-i18n,
  writeShellApplication,
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
      echo "[Nix] Copying aready-built data from ${inventaire-i18n}"

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
  version = "3.0.1-beta";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire-client";
    tag = "v${version}";
    hash = "sha256-Ores7/dQXRVDIW3Namqe4Qpa9PXoeI6ntA1z5eLaGoU=";
  };

  patches = [
    # wikibase-sdk was expected to be provided by inventaire (this was being built in a subdirectory of it)
    # Apply patch which introduces this dependency properly
    # Remove when version > 3.0.1-beta
    (fetchpatch {
      name = "0001-inventaire-client-dependencies-replace-wikidata-sdk-with-wikibase-sdk-wikidata-org.patch";
      url = "https://codeberg.org/inventaire/inventaire-client/commit/cac30096cca66400f29033a010ae9a5d6d0d5f4b.patch";
      hash = "sha256-v4ZW5MfY8bpgVzrXs7NVAGu71BCc6U6cDtVY80tLemU=";
    })
  ];

  npmDepsHash = "sha256-jZQ5rQK8fZQsv/5tYdxYhAE3ha7rSC1++TEwRsp9ucA=";

  postPatch = ''
    patchShebangs scripts

    # inventaire (server-side) is not at a directory above us during build, patch in path to our prebuilt one
    substituteInPlace package.json tsconfig.base.json \
      --replace-fail '"../server/' '"${inventaire-unwrapped}/lib/node_modules/inventaire/dist/server/' \

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

    # TODO
    # Skip building of sitemaps, needs internet access to query wikidata for large JSON files
    mkdir -p ./public/sitemaps
  '';

  # "Your cache folder contains root-owned files" error from NPM
  makeCacheWritable = true;

  # These get produced/modified during the build, but not installed (fully)
  postInstall = ''
    cp -r app public vendor $out/lib/node_modules/inventaire-client/
  '';

  meta = {
    description = "A libre collaborative resources mapper powered by open-knowledge (client-side)";
    homepage = "https://inventaire.io";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
