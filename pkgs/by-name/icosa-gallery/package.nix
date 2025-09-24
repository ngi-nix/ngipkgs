{
  django-admin-tools,
  django-constance,
  django-honeypot,
  django-simple-math-captcha,
  fetchFromGitHub,
  ixxy-email-logger,
  lib,
  makeWrapper,
  python3,
}:
let
  python3' = python3.override {
    packageOverrides = final: prev: {
      # https://github.com/icosa-foundation/icosa-gallery/blob/6a9e27fd6f80b5f90dfcfe83c0064e9ec09f6561/django/requirements.in#L27
      django = final.django_5_1;
    };
  };
  python3Packages = python3'.pkgs;
in
python3Packages.buildPythonApplication rec {
  pname = "icosa-gallery";
  version = "0-unstable-2025-08-27";
  format = "other";

  src = fetchFromGitHub {
    owner = "icosa-foundation";
    repo = "icosa-gallery";
    rev = "6a9e27fd6f80b5f90dfcfe83c0064e9ec09f6561";
    hash = "sha256-aBf7ijT3IebVJLS13FOjcVtBTub7nftEyBNJjggsbuI=";
  };

  sourceRoot = "${src.name}/django";

  patches = [
    ./BASE_DIR.patch
  ];

  dependencies =
    with python3Packages;
    [
      django-admin-tools
      (django-constance.override { inherit python3Packages; })
      (django-honeypot.override { inherit python3Packages; })
      # https://github.com/NixOS/nixpkgs/commit/568c06b293c0eb0ba4efca7f46184947af796bad
      (django-silk.override (previousAttrs: {
        networkx = previousAttrs.networkx.overrideAttrs (previousAttrs: rec {
          version = "3.5";
          src = previousAttrs.src.override {
            inherit version;
            hash = "sha256-1Mb5z4H1LWkjCGZ5a4KvvM3sPbeuT70bZep1D+7VADc=";
          };
        });
      }))
      django-simple-math-captcha
      ixxy-email-logger

      b2sdk
      bcrypt
      boto3
      botocore
      django-autocomplete-light
      django-axes
      django-compressor
      django-cors-headers
      django-debug-toolbar
      django-extensions
      django-ratelimit
      django-redis
      django-import-export
      django-libsass
      django-maintenance-mode
      django-ninja
      django-storages
      django
      gunicorn
      huey
      ijson
      passlib
      pillow
      psycopg2
      pydantic
      pyjwt
      python-magic
      requests
      s3transfer
      sentry-sdk
    ]
    ++ django-import-export.optional-dependencies.all
    ++ pydantic.optional-dependencies.email
    ++ sentry-sdk.optional-dependencies.django;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/icosa-gallery
    cp -r django_project icosa $out/opt/icosa-gallery

    mkdir -p $out/bin
    cp -r manage.py $out/bin/icosa-gallery

    ln -s ${lib.getExe python3Packages.gunicorn} $out/opt/icosa-gallery/gunicorn

    runHook postInstall
  '';

  preFixup = ''
    makeWrapperArgs+=(--prefix PYTHONPATH : "$out/opt/icosa-gallery")
  '';

  postFixup =
    let
      pythonPath = python3Packages.makePythonPath dependencies;
    in
    ''
      wrapProgram $out/opt/icosa-gallery/gunicorn \
        --prefix PYTHONPATH : "$out/opt/icosa-gallery:${pythonPath}"
    '';

  meta = {
    description = "3D model hosting solution";
    homepage = "https://github.com/icosa-foundation/icosa-gallery";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prince213 ];
    teams = with lib.teams; [ ngi ];
    mainProgram = "icosa-gallery";
  };
}
