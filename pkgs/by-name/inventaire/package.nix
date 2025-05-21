# TODO
# - `npm run generate-local-config-from-env` generates a config to override built-in defaults.
#   Generate this config via module.
{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  fetchFromGitHub,
  fetchNpmDeps,
  inventaire-i18n,
  tsx,
  nodejs,
}:

buildNpmPackage rec {
  pname = "inventaire";
  version = "3.0.1-beta";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire";
    tag = "v${version}";
    hash = "sha256-BKsejw+Q5MwBKGFC4FYlOqb08Q5mJ7l5z/A4kGBA9zU=";
  };

  # Could not get upstream lockfile to work, had to regenerate it
  npmDeps = fetchNpmDeps {
    src = ./.;
    hash = "sha256-Q8pMDDOj3SDjvXHRUbdiKTE9AnzcNYk9paAYTt6t2V0=";
  };

  postPatch = ''
    cp -v ${npmDeps.src}/package-lock.json ./

    patchShebangs scripts

    # Don't run this (tries to clone & build inventaire-i18n), just pretend that we did and hook it up to our prebuilt inventaire-i18n
    substituteInPlace package.json \
      --replace-fail './scripts/update_i18n.sh' 'rm -r node_modules/inventaire-i18n && ln -vs ${inventaire-i18n}/lib/node_modules/inventaire-i18n node_modules/'

    # Don't do git stuff, don't build in configurePhase, never try to clone & build inventaire-client
    substituteInPlace scripts/postinstall.sh \
      --replace-fail 'git config' '# git config' \
      --replace-fail 'ln -s ../scripts/githooks' '# ln -s ../scripts/githooks' \
      --replace-fail 'npm run build' 'echo "[Nix] Building later"' \
      --replace-fail '[ -e client ] && exit 0' 'echo "[Nix] Always skipping client build" && exit 0' \

    # tsc is not happy with the way all of these elasticsearch types get imported

    substituteInPlace server/controllers/items/lib/search_users_items.ts \
      --replace-fail \
        "import type { QueryDslBoolQuery, QueryDslQueryContainer } from '@elastic/elasticsearch/lib/api/types.js'" \
        "import type { estypes } from '@elastic/elasticsearch'" \
      --replace-fail 'QueryDslBoolQuery' 'estypes.QueryDslBoolQuery' \
      --replace-fail 'QueryDslQueryContainer' 'estypes.QueryDslQueryContainer' \

    substituteInPlace server/controllers/search/lib/social_query_builder.ts \
      --replace-fail \
        "import type { QueryDslQueryContainer, SearchRequest } from '@elastic/elasticsearch/lib/api/types.js'" \
        "import type { estypes } from '@elastic/elasticsearch'" \
      --replace-fail 'QueryDslQueryContainer' 'estypes.QueryDslQueryContainer' \
      --replace-fail 'SearchRequest' 'estypes.SearchRequest' \

    substituteInPlace server/lib/elasticsearch.ts \
      --replace-fail \
        "import type { SearchRequest, SearchResponse, SearchHitsMetadata } from '@elastic/elasticsearch/lib/api/types.js'" \
        "import type { estypes } from '@elastic/elasticsearch'" \
      --replace-fail 'SearchRequest' 'estypes.SearchRequest' \
      --replace-fail 'SearchResponse' 'estypes.SearchResponse' \
      --replace-fail 'SearchHitsMetadata' 'estypes.SearchHitsMetadata' \

    substituteInPlace server/lib/search_by_distance.ts \
      --replace-fail \
        "import type { SearchRequest } from '@elastic/elasticsearch/lib/api/types.js'" \
        "import type { estypes } from '@elastic/elasticsearch'" \
      --replace-fail 'SearchRequest' 'estypes.SearchRequest' \

    substituteInPlace server/lib/search_by_position.ts \
      --replace-fail \
        "import type { SearchRequest } from '@elastic/elasticsearch/lib/api/types.js'" \
        "import type { estypes } from '@elastic/elasticsearch'" \
      --replace-fail 'SearchRequest' 'estypes.SearchRequest' \
  '';

  makeCacheWritable = true;

  nativeBuildInputs = [
    tsx
  ];

  postConfigure = ''
    npm run postinstall
  '';

  postInstall = ''
    cp -r dist $out/lib/node_modules/inventaire/

    # TODO
    # One link wants to point at inventaire-client, most of the others at generated files
    # Just delete broken ones for now, and create empty dirs in their place
    for candidate in $out/lib/node_modules/inventaire/dist/*; do
      if [ -L "$candidate" ]; then
        linkName="$(basename "$candidate")"
        rm "$candidate"
        if [ -e "$(dirname "$candidate")/../''${linkName}" ]; then
          ln -vs ../"$linkName" "$candidate"
        else
          mkdir "$candidate"
        fi
      fi
    done

    # Launcher
    mkdir -p $out/bin
    cat <<EOF >$out/bin/inventaire
    #!/bin/sh

    ${lib.getExe nodejs} $out/lib/node_modules/inventaire/dist/server/server.js
    EOF
    chmod +x $out/bin/inventaire

    # When this gets installed, the change to the inventaire-i18n version in node_modules doesn't get copied
    # Run the script again to point it at our inventaire-i18n again
    pushd $out/lib/node_modules/inventaire
    npm run update-i18n
    popd
  '';

  meta = {
    description = "A libre collaborative resources mapper powered by open-knowledge (server-side)";
    homepage = "https://inventaire.io";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
