{
  lib,
  gettext,
  python3,
  fetchFromGitHub,
  fetchpatch,
  fetchPypi,
  pretalx,
  pretalx-frontend,
  nodejs,
  withPlugins ? [],
}:
with builtins; let
  python = python3.override {
    packageOverrides = self: super: {
      django-formtools = super.django-formtools.overridePythonAttrs rec {
        version = "2.3";
        src = fetchPypi {
          inherit version;
          pname = "django-formtools";
          hash = "sha256-lmO27KZHd7aNbUFC762Fl/6aaFkkZzslqoodz/TbAMM=";
        };
      };
    };
  };
in
  python.pkgs.buildPythonApplication rec {
    pname = "pretalx";
    version = "2023.1.0";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = "v${version}";
      hash = "sha256-Few4Ojd2i0ELKWPJfkmfd3HeKFx/QK+aP5hYAHDdHeE=";
    };

    outputs = ["out" "static"];

    patches = [
      (fetchpatch {
        url = "https://github.com/pretalx/pretalx/pull/1579.patch";
        hash = "sha256-YVfD4h6bpTC3xIRHwDdpTf+njGZppcGLxcOzT3aMGAw=";
      })
    ];

    nativeBuildInputs = [
      gettext
      nodejs
      pretalx-frontend
    ];

    propagatedBuildInputs = with python.pkgs;
      [
        beautifulsoup4
        bleach
        celery
        css-inline
        csscompressor
        cssutils
        defusedcsv
        django
        django-bootstrap4
        django-compressor
        django-context-decorator
        django-countries
        django-csp
        django-filter
        django-formset-js-improved
        django-formtools
        django-hierarkey
        django-i18nfield
        django-libsass
        django-scopes
        djangorestframework
        inlinestyler
        libsass
        markdown
        pillow
        publicsuffixlist
        python-dateutil
        pytz
        qrcode
        reportlab
        requests
        rules
        urlman
        vobject
        whitenoise
        zxcvbn
      ]
      ++ withPlugins;

    passthru.optional-dependencies = with python.pkgs; {
      mysql = [mysqlclient];
      postgres = [psycopg2];
      redis = [redis];
    };

    postPatch = ''
      substituteInPlace src/pretalx/common/management/commands/rebuild.py --replace \
        'subprocess.check_call(["npm", "run", "build"], cwd=frontend_dir, env=env)' '#'
    '';

    postBuild = ''
      rm -r ./src/pretalx/frontend/schedule-editor
      ln -s ${pretalx-frontend}/lib/node_modules/@pretalx/schedule-editor ./src/pretalx/frontend/schedule-editor

      PYTHONPATH=$PYTHONPATH:./src python -m pretalx rebuild
    '';

    doCheck = false;

    postInstall = ''
      mkdir -p $out/bin
      cp ./src/manage.py $out/bin/pretalx

      # the processed source files are in the static output
      rm -rf $out/${python.sitePackages}/pretalx/static

      mkdir -p $static

      # Copy generated static files into dedicated output.
      cp -r ./src/static.dist/** $static/

      # Copy frontend files.
      cp -r ${pretalx-frontend}/lib/node_modules/@pretalx/schedule-editor/dist/* $static
    '';

    nativeCheckInputs = with python.pkgs;
      [
        faker
        freezegun
        pytest-django
        pytest-mock
        pytest-xdist
        pytestCheckHook
        responses
      ]
      ++ lib.flatten (builtins.attrValues passthru.optional-dependencies);

    passthru = {
      python = python;
      PYTHONPATH = "${python.pkgs.makePythonPath propagatedBuildInputs}:${pretalx.outPath}/${python.sitePackages}";
    };

    meta = with lib; {
      description = "Conference planning tool: CfP, scheduling, speaker management";
      homepage = "https://github.com/pretalx/pretalx";
      license = licenses.asl20;
      maintainers = with maintainers;
        [
          andresnav
          imincik
          lorenzleutgeb
        ]
        ++ (with (import ../../maintainers/maintainers-list.nix); [augustebaum kubaneko]);
    };
  }
