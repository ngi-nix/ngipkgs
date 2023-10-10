{
  lib,
  gettext,
  python3,
  fetchFromGitHub,
  fetchPypi,
  nixosTests,
  pretalx,
  pretalx-frontend,
  nodejs,
  withPlugins ? [],
}: let
  inherit
    (builtins)
    attrValues
    ;

  inherit
    (lib)
    flatten
    licenses
    maintainers
    ;

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
    version = "2023.1.3";
    format = "pyproject";

    src = fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = "v${version}";
      hash = "sha256-YxmkjfftNrInIcSkK21wJXiEU6hbdDa1Od8p+HiLprs=";
    };

    outputs = ["out" "static"];

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

    postInstall = ''
      mkdir -p $out/bin
      cp ./src/manage.py $out/bin/pretalx

      # The processed source files are in the static output,
      # except for fonts, which are duplicated.
      # See <https://github.com/pretalx/pretalx/issues/1585>
      # for more details.
      find $out/${python.sitePackages}/pretalx/static \
        -mindepth 1 \
        -not -path "$out/${python.sitePackages}/pretalx/static/fonts*" \
        -delete

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
        pytest-cov
        pytest-django
        pytest-mock
        pytest-xdist
        pytestCheckHook
        responses
      ]
      ++ flatten (attrValues passthru.optional-dependencies);

    doCheck = true;

    preCheck = ''
      export PRETALX_CONFIG_FILE="$src/src/tests/ci_sqlite.cfg"
      cd src
    '';

    disabledTests = [
      # AssertionError: assert 'https://localhost' == None
      "test_change_custom_domain[http://localhost-None]"
      # npm run i18n:extract
      "test_common_custom_makemessages_does_not_blow_up"
      # Expected to perform X queries or less but Y were done
      "test_schedule_export_public"
      "test_schedule_frab_json_export"
      "test_schedule_frab_xml_export"
    ];

    passthru = {
      inherit python;
      PYTHONPATH = "${python.pkgs.makePythonPath propagatedBuildInputs}:${pretalx.outPath}/${python.sitePackages}";

      tests.pretalx = nixosTests.pretalx;
    };

    meta = {
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
      ngi = {
        project = "Rosenpass";
        options = [["services" pname]];
      };
    };
  }
