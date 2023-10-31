{
  fetchhg,
  python3,
  wokkel,
  sat-tmp,
}: let
  version = "0.4.0";
in
  python3.pkgs.buildPythonApplication {
    pname = "libervia-pubsub";
    inherit version;

    src = fetchhg {
      url = "https://repos.goffi.org/libervia-pubsub";
      rev = "v${version}";
      hash = "sha256-5uf3hAjlhUupsAO2TaKTE0SqI74CF/6CeWVczVcQKiE=";
    };

    buildInputs = with python3.pkgs;
      [
        attrs
        automat
        cffi
        constantly
        cryptography
        hyperlink
        idna
        incremental
        psycopg2
        pyasn1
        pyasn1-modules
        pycparser
        pyopenssl
        python-dateutil
        service-identity
        six
        twisted
        uuid
        zope_interface
      ]
      ++ [
        sat-tmp
        wokkel
      ];

    # meta = with lib; {
    #   changelog = "https://github.com/pytest-dev/pytest/releases/tag/${version}";
    #   description = "Framework for writing tests";
    #   homepage = "https://github.com/pytest-dev/pytest";
    #   license = licenses.mit;
    #   maintainers = with maintainers; [ domenkozar lovek323 madjar lsix ];
    # };
  }
