{
  lib,
  fetchhg,
  python3,
  sat-tmp,
  wokkel
}:
python3.pkgs.buildPythonApplication {
  pname = "libervia-backend";
  version = "unstable-2023-10-18";
  pyproject = true;

  src = fetchhg {
    url = "https://repos.goffi.org/libervia-backend";
    rev = "646b328b3980";
    hash = "sha256-3X2s9MHbe1LzgL3oT68l6Bi4HpICT1QModIAY+cZno0=";
  };

  buildInputs = with python3.pkgs; [
    hatchling
    sat-tmp
    wokkel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    alembic
    lxml
    pyxdg
    shortuuid
    twisted.optional-dependencies.tls
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    aiosmtpd
  ];

  # Ignoring end-to-end tests because they run in Docker containers
  pytestFlagsArray = [
    "--ignore=tests/e2e"
  ];

  meta = with lib; {
    description = "An XMPP client with multiple frontends";
    homepage = "https://libervia.org";
    license = licenses.gpl3Plus;
  };
}
