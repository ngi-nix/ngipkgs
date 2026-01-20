{
  lib,
  python3,
  fetchFromGitLab,
  addBinToPathHook,
  writeText,
}:

python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "py3dtiles";
  version = "12.0.0";
  pyproject = true;

  src = fetchFromGitLab {
    owner = "py3dtiles";
    repo = "py3dtiles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m8c+g9XXbg9OSC+NNoQkw4RKXvNFRIPWkDjAs6oH3kc=";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    lz4
    mapbox-earcut
    numba
    numpy
    psutil
    pygltflib
    pyproj
    pyzmq
  ];

  optional-dependencies = with python3.pkgs; {
    ifc = [
      ifcopenshell
      lark
    ];
    las = [
      laspy
    ];
    ply = [
      plyfile
    ];
    postgres = [
      psycopg2-binary
    ];
  };

  nativeCheckInputs =
    with python3.pkgs;
    [
      pytestCheckHook
      pytest-benchmark
      pytest-cov-stub
    ]
    ++ (with finalAttrs.passthru.optional-dependencies; ply ++ las ++ ifc);

  nativeInstallCheckInputs = [
    addBinToPathHook
  ];

  # from .gitlab-ci.yml
  # note: nativeCheckInputs are also available for installCheck
  installCheckPhase =
    let
      testScript = writeText "test.py" /* py */ ''
        from py3dtiles.tileset.utils import number_of_points_in_tileset
        from pathlib import Path
        exit(number_of_points_in_tileset(Path("3dtiles/tileset.json")) != 22300)
      '';
    in
    ''
      runHook preInstallCheck
      py3dtiles --help
      py3dtiles info tests/fixtures/pointCloudRGB.pnts
      py3dtiles convert --out test1 ./tests/fixtures/simple.xyz
      py3dtiles convert --out test2 ./tests/fixtures/with_srs_3857.las
      py3dtiles convert tests/fixtures/simple.ply
      runHook postInstallCheck
    '';

  pythonRelaxDeps = [
    "numba"
    "numpy"
    "pyzmq"
  ];

  pythonImportsCheck = [
    "py3dtiles"
  ];

  meta = {
    changelog = "https://py3dtiles.org/main/changelog.html";
    description = "Python module to manage 3DTiles format";
    downloadPage = "https://gitlab.com/py3dtiles/py3dtiles";
    homepage = "https://py3dtiles.org";
    license = lib.licenses.asl20;
    mainProgram = "py3dtiles";
    maintainers = with lib.maintainers; [ phanirithvij ];
    teams = with lib.teams; [ ngi ];
  };
})
