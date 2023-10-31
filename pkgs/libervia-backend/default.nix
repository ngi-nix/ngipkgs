{
  lib,
  fetchhg,
  python3,
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
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    aiosmtpd
    twisted
    # FIXME: The version of the `sh` Python package is not correct
    sh
  ];

  # FIXME: The version of the `sh` Python package is not correct
  # See <https://github.com/ngi-nix/ngipkgs/issues/87>
  doCheck = true;

  #disabledTestsPaths = ["tests/e2e/*"];
  pytestFlagsArray = [
    "tests/"
    "--ignore=tests/e2e"
  ];

  # passthru = {
  #   python = python3;
  #   PYTHONPATH = "${python3.pkgs.makePythonPath propagatedBuildInputs}:${pretalx.outPath}/${python3.sitePackages}";

  #   tests.pretalx = nixosTests.pretalx;
  # };

  meta = with lib; {
    description = "An XMPP client with multiple frontends";
    homepage = "https://libervia.org";
    license = licenses.gpl3Plus;
  };
}
