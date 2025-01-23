{
  stdenv,
  python3,
  lib,
  fetchFromGitHub,
  fetchpatch,
  firefox,
  geckodriver,
  which,
}:

let
  python =
    let
      packageOverrides = self: super: {
        selenium = super.selenium.overridePythonAttrs (old: rec {
          version = "4.28.0";
          src = fetchFromGitHub {
            owner = "SeleniumHQ";
            repo = "selenium";
            tag = "selenium-${version}" + lib.optionalString (lib.versions.patch version != "0") "-python";
            hash = "sha256-b5xwuZ4lcwLbGhJuEmHYrFXoaTW/M0ABdK3dvbpj8oM=";
          };
          patches = [
            (fetchpatch {
              name = "dont-build-the-selenium-manager.patch";
              url = "https://github.com/NixOS/nixpkgs/raw/6c4fd2e7e7db0ffbd2d2653e2b046cac925cbb70/pkgs/development/python-modules/selenium/dont-build-the-selenium-manager.patch";
              hash = "sha256-zE3laXDuDliF8q2xol8ZpA/Q7tL0clAfKIXdiHimvNc=";
            })
          ];
        });
      };
    in
    python3.override {
      inherit packageOverrides;
      self = python;
    };

  python3Packages = python.pkgs;
in
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

  nativeBuildInputs = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [ selenium ];

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
    maintainers = [ ];
  };
}
