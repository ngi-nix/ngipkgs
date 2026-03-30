{
  lib,
  fetchFromGitLab,
  python3,
}:

python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "cryptodatahub";
  version = "1.1.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "coroner";
    repo = "cryptodatahub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tz2VbWS5/sGjRsOKR7eWpWAJVNv1QMSjkepI7fVZq6w=";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    asn1crypto
    attrs
    python-dateutil
    urllib3
  ];

  nativeCheckInputs = with python3.pkgs; [
    beautifulsoup4
    pyfakefs
    pytestCheckHook
  ];

  pythonImportsCheck = [ "cryptodatahub" ];

  disabledTests = [
    # fails due to certificate expiry
    # see https://gitlab.com/coroner/cryptodatahub/-/work_items/38
    "test_validity"
    # pytest incorrectly collects abstract base classes
    "TestClasses"
  ];

  disabledTestPaths = [
    # failing tests
    "test/updaters/test_common.py"
    # Tests require network access
    "test/common/test_utils.py"
  ];

  meta = {
    description = "Repository of cryptography-related data";
    homepage = "https://gitlab.com/coroner/cryptodatahub";
    changelog = "https://gitlab.com/coroner/cryptodatahub/-/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mpl20;
    teams = with lib.teams; [ ngi ];
  };
})
