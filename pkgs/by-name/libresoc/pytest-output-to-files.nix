{
  fetchFromLibresoc,
  python39Packages,
}:
with python39Packages;
  buildPythonPackage {
    name = "pytest-output-to-files";
    version = "unstable-2024-03-31";

    src = fetchFromLibresoc {
      inherit pname;
      rev = "e4d64e643acb1cd6218fc61910ab6266d3da7573"; # HEAD @ version date
      hash = "sha256-ES8zZ9s6wGcqw60NoN4tZf/Dq/sBvl+UDYrXuOgfMxI=";
    };

    nativeCheckInputs = [pytestCheckHook];
  }
