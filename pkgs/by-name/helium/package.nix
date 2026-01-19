{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  firefox,
  geckodriver,
  which,
}:

python3Packages.buildPythonPackage rec {
  pname = "helium";
  version = "6.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mherrmann";
    repo = "helium";
    rev = "refs/tags/v${version}";
    hash = "sha256-d64nzFB8nzLZ7nmhh+xcui3jPFAbyAF+diRksnujzGU=";
  };

  strictDeps = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    selenium
  ];

  nativeCheckInputs = [
    firefox
    geckodriver
    which
  ]
  ++ (with python3Packages; [
    pytestCheckHook
  ]);

  checkInputs = with python3Packages; [
    psutil
  ];

  # Selenium doesn't support testing on all setups
  doCheck =
    stdenv.hostPlatform.isDarwin || (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64);

  # Selenium setup
  preCheck = ''
    export HOME=$PWD
    export TEST_BROWSER=firefox
    export SE_OFFLINE=true
  '';

  disabledTestPaths = [
    # All of the tests here fail, maybe because we force a driver to be found via envvars?
    "tests/api/test_no_driver.py"

    # New tests, not sure why they fail. Maybe due to forced firefox?
    "tests/api/test_write.py"
  ];

  pythonImportsCheck = [
    "helium"
  ];

  meta = {
    description = "Lighter web automation with Python";
    homepage = "https://github.com/mherrmann/helium";
    license = lib.licenses.mit;
    teams = with lib.teams; [ ngi ];
  };
}
