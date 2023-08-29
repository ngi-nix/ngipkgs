{
  lib,
  gettext,
  python3,
  fetchFromGitHub,
  fetchPypi,
  pretalx,
  withPlugins ? [],
}:
with builtins; let
  python = python3.override {
    packageOverrides = self: super: {
      django-formtools = super.django-formtools.overridePythonAttrs rec {
        version = "2.3";
        src = fetchPypi {
          pname = "django-formtools";
          inherit version;
          hash = "sha256-lmO27KZHd7aNbUFC762Fl/6aaFkkZzslqoodz/TbAMM=";
        };
      };
    };
  };
in
  python.pkgs.buildPythonApplication rec {
    pname = "pretalx";
    version = "2.3.2";
    format = "setuptools";

    src = fetchFromGitHub {
      owner = "pretalx";
      repo = "pretalx";
      rev = "v${version}";
      hash = "sha256-EtREzTMXLsNSm7MkaK0Ho5eUwNisp0+RO39LwOyVyxo=";
    };

    outputs = [
      "out"
      "static"
    ];

    sourceRoot = "source/src";

    pythonRelaxDeps = [
      "beautifulsoup4"
      "bleach"
      "celery"
      "cssutils"
      "defusedcsv"
      "django-bootstrap4"
      "django-compressor"
      "django-filter"
      "django-formset-js-improved"
      "django-hierarkey"
      "django-scopes"
      "djangorestframework"
      "libsass"
      "Markdown"
      "Pillow"
      "publicsuffixlist"
      "reportlab"
      "requests"
      "rules"
      "whitenoise"
    ];

    nativeBuildInputs = [
      gettext
      python.pkgs.pythonRelaxDepsHook
    ];

    propagatedBuildInputs = with python.pkgs; [
      beautifulsoup4
      bleach
      celery
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
    ] ++ withPlugins;

    passthru.optional-dependencies = {
      mysql = with python.pkgs; [mysqlclient];
      postgres = with python.pkgs; [psycopg2];
      redis = with python.pkgs; [django-redis redis];
    };

    postBuild = ''
      python -m pretalx rebuild
    '';

    postInstall = ''
      mkdir -p $out/bin
      cp ./manage.py $out/bin/pretalx

      # the processed source files are in the static output
      rm -rf $out/${python.sitePackages}/pretalx/static

      # copy generated static files into dedicated output
      mkdir -p $static
      cp -r ./static.dist/** $static/
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

    disabledTests = [
      # Expected to perform X queries or less but Y were done
      "test_schedule_export_public"
      "test_schedule_frab_json_export"
      "test_schedule_frab_xml_export"
    ];

    passthru = {
      python = python;
      PYTHONPATH = "${python.pkgs.makePythonPath propagatedBuildInputs}:${pretalx.outPath}/${python.sitePackages}";
      # tests = { inherit (nixosTests) pretalx; }; # Used in nixpkgs
    };

    meta = with lib; {
      description = "Conference planning tool: CfP, scheduling, speaker management";
      homepage = "https://github.com/pretalx/pretalx";
      license = licenses.asl20;
      maintainers = with maintainers; [hexa];
    };
  }
