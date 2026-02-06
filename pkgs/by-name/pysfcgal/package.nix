{
  lib,
  python3,
  fetchFromGitLab,
  sfcgal,
}:

python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "pysfcgal";
  version = "2.2.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "sfcgal";
    repo = "pysfcgal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/G6yC7u2CYM7D9xO2IOB8+AjWc4ErzTIdvHmwGRxXBc=";
  };

  strictDeps = true;

  buildInputs = [
    sfcgal
  ];

  build-system = with python3.pkgs; [
    setuptools
    wheel
  ];

  dependencies = with python3.pkgs; [
    cffi
  ];

  pythonImportsCheck = [
    "pysfcgal"
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  checkInputs = with python3.pkgs; [
    icontract
  ];

  preCheck = ''
    rm -rf pysfcgal
  '';

  disabledTests = [
    "test_wrap_geom_segfault"
  ];

  meta = {
    description = "Python wrapper for SFCGAL";
    homepage = "https://gitlab.com/sfcgal/pysfcgal";
    changelog = "https://gitlab.com/sfcgal/pysfcgal/-/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    teams = with lib.teams; [
      geospatial
      ngi
    ];
  };
})
