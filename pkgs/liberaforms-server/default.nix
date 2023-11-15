{
  fetchFromGitLab,
  python3,
}: let
  pname = "liberaforms-server";
  version = "2.1.2";
in
  python3.pkgs.buildPythonPackage {
    inherit pname version;
    format = "setuptools";

    src = fetchFromGitLab {
      owner = "liberaforms";
      repo = "liberaforms";
      rev = "v${version}";
      sha256 = "sha256-JNs7SU9imLzWeVFGx2gxqqt8Bbea7SsvoHXJBxxona4=";
    };

    propagatedBuildInputs = with python3.pkgs; [
      aiosmtpd
      alembic
      atpublic
      attrs
      babel
      beautifulsoup4
      bleach
      cachelib
      certifi
      cffi
      charset-normalizer
      click
      cryptography
      dnspython
      email-validator
      feedgen
      flask
      flask-babel
      flask-login
      flask-marshmallow
      flask-migrate
      # flask-session2
      flask-sqlalchemy
      flask-wtf
      greenlet
      gunicorn
      idna
      importlib-metadata
      importlib-resources
      iniconfig
      itsdangerous
      jinja2
      ldap3
      lxml
      mako
      markdown
      markupsafe
      marshmallow
      marshmallow-sqlalchemy
      minio
      packaging
      passlib
      # password-strength
      pillow
      platformdirs
      pluggy
      portpicker
      prometheus-client
      psutil
      psycopg2
      py
      pyasn1
      pycodestyle
      pycparser
      pyjwt
      pyparsing
      pypng
      pyqrcode
      python-dateutil
      python-dotenv
      python-magic
      pytz
      requests
      six
      snowballstemmer
      soupsieve
      sqlalchemy
      # sqlalchemy-json
      toml
      typed-ast
      unicodecsv
      unidecode
      urllib3
      webencodings
      werkzeug
      wtforms
      zipp
    ];

    preBuild = ''
      cat > setup.py << EOF
      from setuptools import setup, find_packages

      with open('requirements.txt') as f:
          install_requires = f.read().splitlines()

      setup(
        name='${pname}',
        packages=find_packages(),
        version='${version}',
        install_requires=install_requires,
      )
      EOF
    '';

    checkPhase = ''
      runHook preCheck
      cd ./tests

      export TEST_DB_USER=TEST_DB_USER
      export TEST_DB_PASSWORD=TEST_DB_PASSWORD
      export TEST_DB_HOST=TEST_DB_HOST
      export TEST_DB_NAME=TEST_DB_NAME

      cp test.ini.example test.ini
      pytest -v unit

      runHook postCheck
    '';

    nativeCheckInputs = with python3.pkgs; [
      pytest
      #pytestCheckHook
      # smtpdfix
    ];
  }
