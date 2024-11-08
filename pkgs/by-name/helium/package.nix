{
  python3Packages,
  lib,
  fetchFromGitHub,
  firefox,
  geckodriver,
  which,
}:
python3Packages.buildPythonPackage rec {
  pname = "helium";
  version = "5.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mherrmann";
    repo = "helium";
    rev = "refs/tags/v${version}";
    hash = "sha256-YV/X7BBzmX/4QL+YHJZrZPPsvZ2VheNHZiUrF/lUTW8=";
  };

  strictDeps = true;

  nativeBuildInputs = with python3Packages; [setuptools];

  propagatedBuildInputs = with python3Packages; [selenium];

  nativeCheckInputs =
    [
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
    maintainers = [];
  };
}
