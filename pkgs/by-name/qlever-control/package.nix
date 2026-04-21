{
  lib,
  python3,
  fetchFromGitHub,
}:
let
  python3' = python3.override {
    packageOverrides = final: prev: {
      requests-sse = final.callPackage ./requests-sse.nix { };
    };
  };

  python3Packages = python3'.pkgs;
in

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "qlever-control";
  version = "0.5.46";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "qlever-dev";
    repo = "qlever-control";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vXSVrNfz4gRBCrTi0D+sXtfsAZwv7HO67zs7wh98cOY=";
  };

  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  dependencies = with python3Packages; [
    argcomplete
    psutil
    pyyaml
    rdflib
    requests-sse
    termcolor
    tqdm
  ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];

  pythonImportsCheck = [
    "qlever"
  ];

  meta = {
    description = "Command-line tool for controlling the QLever graph database";
    homepage = "https://github.com/qlever-dev/qlever-control";
    mainProgram = "qlever-control";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
