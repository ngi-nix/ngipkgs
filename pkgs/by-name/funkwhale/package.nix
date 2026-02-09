{
  lib,
  python3,
  fetchFromGitLab,
  postgresql,
  postgresqlTestHook,
  redisTestHook,
  funkwhale,
  runCommand,

  # Frontend
  stdenv,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  nodejs,

  nix-update-script,
}:
let
  python = python3;

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
  version = "1.4.1";
  pyproject = true;

  src = fetchFromGitLab {
    domain = "dev.funkwhale.audio";
    owner = "funkwhale";
    repo = "funkwhale";
    tag = version;
    hash = "sha256-eCSYdZZdxfvUk1WGSGWpsme8K6sdboFGaE9eixFVNg8=";
  };

  sourceRoot = "${src.name}/api";

  patches = [
    # `unicode-slugify` was removed from nixpkgs.
    # See https://github.com/NixOS/nixpkgs/pull/448893.
    ./replace-unicode-slugify.patch

    # The function was removed in an update.
    ./fix-allauth-internal-function-use.patch

    # Broken in <https://github.com/django-oauth/django-oauth-toolkit/commit/13f0aceb010eececfb581a0e21f013f47a8f5f6b#diff-a7fb1c13746762fee6dcacf6b9f28079ef7f1567104660aa5a8d6ca388ccc838R123-R130>
    ./fix-oob-schemes.patch

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
      typesense

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

      yarnOfflineCache = fetchYarnDeps {
        yarnLock = "${src}/front/yarn.lock";
        hash = "sha256-ouDw90BqwlzIhaiWmo3gQUOX+6O/8zgHJEvV5V17BVI=";
      };

      yarnBuildScript = "build:deployment";

      nativeBuildInputs = [
        yarnConfigHook
        yarnBuildHook
        nodejs
      ];

      installPhase = ''
        runHook preInstall

        cp -r dist $out

        runHook postInstall
      '';

      meta = meta // {
        description = "Frontend for the federated audio platform, Funkwhale";
      };
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "frontend"
      ];
    };

    inherit meta;
  };
}
