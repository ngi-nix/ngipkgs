{
  lib,
  python3,
  fetchFromGitLab,
  postgresql,
  postgresqlTestHook,
  redisTestHook,
  funkwhale,
  runCommand,
  typesense,
  curl,

  # Frontend
  stdenv,
  yarn-berry_4,
  nodejs,
  cypress,
  dart-sass,

  nix-update-script,
}:
let
  python = python3;
  yarn-berry = yarn-berry_4;

  meta = {
    description = "Federated platform for audio streaming, exploration, and publishing";
    homepage = "https://www.funkwhale.audio/";
    downloadPage = "https://dev.funkwhale.audio/funkwhale/funkwhale";
    changelog = "https://docs.funkwhale.audio/changelog.html";
    license = lib.licenses.agpl3Only;
    teams = [ lib.teams.ngi ];
    mainProgram = "funkwhale-manage";
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "funkwhale";
  version = "2.0.0";
  pyproject = true;

  src = fetchFromGitLab {
    domain = "dev.funkwhale.audio";
    owner = "funkwhale";
    repo = "funkwhale";
    tag = version;
    hash = "sha256-hMxVWnKa2n8ZmY8A2J8603tpyRvTH/Po37gZDBmRKWY=";
  };

  sourceRoot = "${src.name}/api";

  patches = [
    # `unicode-slugify` was removed from nixpkgs.
    # See https://github.com/NixOS/nixpkgs/pull/448893.
    ./replace-unicode-slugify.patch

    ./fix-root-filesystem-tests.patch
  ];

  build-system = with python.pkgs; [
    poetry-core
  ];

  # Everything is pinned to specific versions.
  pythonRelaxDeps = true;
  pythonRemoveDeps = [
    # Not used directly.
    "gunicorn"
  ];

  dependencies =
    with python.pkgs;
    [
      # Django
      dj-rest-auth
      django
      django-allauth
      django-cache-memoize
      django-cacheops
      django-cleanup
      django-cors-headers
      django-debug-toolbar
      django-dynamic-preferences
      django-environ
      django-filter
      django-oauth-toolkit
      django-redis
      django-storages
      django-versatileimagefield
      djangorestframework
      drf-spectacular
      markdown
      persisting-theory
      psycopg2-binary
      redis

      # Django LDAP
      django-auth-ldap
      python-ldap

      # Channels
      channels
      channels-redis

      # Celery
      kombu
      celery

      # Deployment
      uvicorn

      # Libs
      aiohttp
      arrow
      bleach
      boto3
      click
      cryptography
      defusedxml
      feedparser
      httpx
      python-ffmpeg
      liblistenbrainz
      musicbrainzngs
      mutagen
      pillow
      pyld
      python-magic
      requests
      requests-http-message-signatures
      sentry-sdk
      watchdog
      troi
      lb-matching-tools
      unidecode
      pycountry

      # Typesense
      #typesense
      # Remove once https://github.com/NixOS/nixpkgs/pull/503394 is merged
      (python3.pkgs.callPackage ./deps/typesense { inherit typesense curl; })

      ipython
      pluralizer
      service-identity
      python-slugify
    ]
    ++ channels.optional-dependencies.daphne
    ++ uvicorn.optional-dependencies.standard;

  nativeCheckInputs = with python.pkgs; [
    postgresql
    postgresqlTestHook
    redisTestHook
    pyfakefs
    aioresponses
    factory-boy
    faker
    ipdb
    pytest
    pytest-asyncio
    prompt-toolkit
    pytest-django
    pytest-env
    pytest-mock
    pytest-randomly
    pytest-sugar
    requests-mock
    django-extensions
  ];

  postgresqlTestUserOptions = "LOGIN SUPERUSER";
  checkPhase = ''
    runHook preCheck

    DATABASE_URL="postgresql:///$PGDATABASE?host=$PGHOST&user=$PGUSER" \
    FUNKWHALE_URL="https://example.com" \
    DJANGO_SETTINGS_MODULE="config.settings.local" \
    CACHE_URL="redis://$REDIS_SOCKET:6379/0" \
    python -m django migrate --no-input

    runHook postCheck
  '';

  passthru = {
    inherit python;

    static = runCommand "funkwhale-static" { } ''
      FUNKWHALE_URL="https://example.com" \
      DJANGO_SECRET_KEY="" \
      STATIC_ROOT="$out" \
        ${lib.getExe funkwhale} collectstatic --no-input
    '';

    frontend = stdenv.mkDerivation {
      pname = "funkwhale-frontend";
      inherit version src;
      sourceRoot = "${src.name}/front";

      missingHashes = ./missing-hashes.json;
      offlineCache = yarn-berry.fetchYarnBerryDeps {
        yarnLock = "${src}/front/yarn.lock";
        # TODO update script
        # yarn-berry-fetcher missing-hashes $(nix-build -A funkwhale.frontend.src)/front/yarn.lock >pkgs/by-name/funkwhale/missing-hashes.json
        missingHashes = ./missing-hashes.json;
        hash = "sha256-II/9X4JILGJli5gSznIfKMGlDzp84IMJS7l1qV2KNOk=";
      };

      env = {
        CYPRESS_INSTALL_BINARY = 0;
        CYPRESS_RUN_BINARY = lib.getExe cypress;
      };

      nativeBuildInputs = [
        yarn-berry.yarnBerryConfigHook
        yarn-berry
        nodejs
        dart-sass
      ];

      buildPhase = ''
        runHook preBuild

        # force sass-embedded to use our own sass instead of the bundled one
        substituteInPlace node_modules/sass-embedded/dist/lib/src/compiler-path.js \
            --replace-fail 'compilerCommand = (() => {' 'compilerCommand = (() => { return ["${lib.getExe dart-sass}"];'

        yarn run build:deployment
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        cp -r dist $out
        runHook postInstall
      '';

      meta = meta // {
        description = "Frontend for the federated audio platform, Funkwhale";
      };
    };

    # TODO experimental combinator
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "frontend"
      ];
    };

    inherit meta;
  };
}
