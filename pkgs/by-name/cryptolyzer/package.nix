{
  lib,
  fetchFromGitLab,
  python3,
  cryptoparser,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cryptolyzer";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "coroner";
    repo = "cryptolyzer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qfE6/jHJD+I2AeIl3uUcGVkAteAHSvZquLvh2fCxJB0=";
  };

  patches = [
    # https://gitlab.com/coroner/cryptolyzer/-/merge_requests/4
    ./fix-dirs-exclude.patch
  ];

  pythonRemoveDeps = [ "bs4" ];

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cryptoparser
  ]
  ++ (with python3.pkgs; [
    attrs
    beautifulsoup4
    certvalidator
    colorama
    dnspython
    pathlib2
    pyfakefs
    python-dateutil
    requests
    urllib3
  ]);

  # Tests require networking
  doCheck = false;

  postInstall = ''
    find $out -name "__pycache__" -type d | xargs rm -rv

    # Prevent creating more binary byte code later (e.g. during
    # pythonImportsCheck)
    export PYTHONDONTWRITEBYTECODE=1
  '';

  pythonImportsCheck = [ "cryptolyzer" ];

  meta = {
    description = "Cryptographic protocol analyzer";
    homepage = "https://gitlab.com/coroner/cryptolyzer";
    changelog = "https://gitlab.com/coroner/cryptolyzer/-/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    mainProgram = "cryptolyze";
    teams = with lib.teams; [ ngi ];
  };
})
