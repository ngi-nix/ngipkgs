{python3Packages}:
python3Packages.buildPythonPackage {
  name = "build-matrix";
  format = "pyproject";
  src = ./.;
  propagatedBuildInputs = with python3Packages; [networkx setuptools];
  meta.mainProgram = "build-matrix";
}
