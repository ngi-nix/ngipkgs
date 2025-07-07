{
  lib,
  buildNpmPackage,
  fetchFromGitea,
  fetchNpmDeps,
  inventaire-i18n,
  tsx,
}:

buildNpmPackage rec {
  pname = "inventaire-unwrapped";
  version = "4.0.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "inventaire";
    repo = "inventaire";
    tag = "v${version}";
    hash = "sha256-tYVz/elb9AbqdMDBgiyQtOrQzas+It3hhgBc2wzl74w=";
  };

  # Cannot handle git+https://codeberg.org source url, but it later gets fetched manually anyway
  # https://github.com/npm/hosted-git-info/issues/117
  # Dropped it from package.json, regenerated package-lock.json
  npmDeps = fetchNpmDeps {
    src = ./.;
    hash = "sha256-y3zX6tfjIX81Fvp01yllIU0C7VudyS3l5l2h4UzRbtQ=";
  };

  postPatch = ''
    cp -v ${npmDeps.src}/package{,-lock}.json ./

    patchShebangs scripts

    # Don't run this (tries to clone & build inventaire-i18n), just pretend that we did and hook it up to our prebuilt inventaire-i18n
    substituteInPlace package.json \
      --replace-fail './scripts/update_i18n.sh' 'ln -vs ${inventaire-i18n}/lib/node_modules/inventaire-i18n node_modules/'

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

    # Look up some directories relative to CWD, instead of in the installed tree

    substituteInPlace server/lib/auto_rotated_keys.ts \
      --replace-fail "absolutePath('root', 'keys/sessions_keys')" "'keys/sessions_keys'"

    substituteInPlace server/controllers/images/lib/local_client.ts \
      --replace-fail 'resolve(projectRoot, localStorage.directory)' 'localStorage.directory'

    # Please, don't run git to try to find out the revision of the src
    substituteInPlace server/lib/package.ts \
      --replace-fail "await execAsync('git rev-parse --short HEAD').then(({ stdout }) => stdout.trim())" "'${
        if src.tag != null then src.tag else src.rev
      }'" \

    # OpenSearch is not happy with these API URLs, ElasticSearch seems to be fine with the patched ones as well
    substituteInPlace server/db/elasticsearch/init.ts \
      --replace-fail '/_doc/wikidata/test' '/wikidata/_doc/test'
    substituteInPlace server/db/elasticsearch/bulk.ts \
      --replace-fail 'Origin}/_doc/_bulk' 'Origin}/_bulk'
  '';

  makeCacheWritable = true;

  nativeBuildInputs = [
    tsx
  ];

  postInstall = ''
    cp -r dist $out/lib/node_modules/inventaire/

    # One link wants to point at inventaire-client, most of the others at generated files
    # Just delete broken ones for now, and create empty dirs in their place
    for candidate in $out/lib/node_modules/inventaire/dist/*; do
      if [ -L "$candidate" ]; then
        linkName="$(basename "$candidate")"
        rm -v "$candidate"
        if [ -e "$(dirname "$candidate")/../''${linkName}" ]; then
          ln -vs ../"$linkName" "$candidate"
        fi
      fi
    done

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
