{
  lib,
  fetchFromGitLab,
  fetchpatch2,
  python3,
  cryptodatahub,
}:

python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "cryptoparser";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "coroner";
    repo = "cryptoparser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zd305BFM3G8LMQqDwtbwRPy6ooNXJ61UzWBwVewh0F4=";
  };

  patches = [
    (fetchpatch2 {
      url = "https://gitlab.com/coroner/cryptoparser/-/merge_requests/2.diff";
      hash = "sha256-T8dK6OMR41XUMrZ6B7ZybEtljZJOR2QbCiZl04dT3wA=";
    })
  ];

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cryptodatahub
  ]
  ++ (with python3.pkgs; [
    asn1crypto
    attrs
    urllib3
  ]);

  env.PYTHONDONTWRITEBYTECODE = 1;

  nativeCheckInputs = with python3.pkgs; [
    pyfakefs
    pytestCheckHook
  ];

  disabledTests = [
    # pytest incorrectly collects abstract base classes
    "TestCasesBasesHttpHeader"
  ];

  postInstall = ''
    find $out -name __pycache__ -type d | xargs rm -rv
  '';

  pythonImportsCheck = [ "cryptoparser" ];

  meta = {
    description = "Security protocol parser and generator";
    homepage = "https://gitlab.com/coroner/cryptoparser";
    changelog = "https://gitlab.com/coroner/cryptoparser/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    teams = with lib.teams; [ ngi ];
  };
})
