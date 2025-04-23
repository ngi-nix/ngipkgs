{
  lib,
  fetchFromLibresoc,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "pytest-output-to-files";
  version = "unstable-2024-03-31";
  pyproject = true;

  src = fetchFromLibresoc {
    inherit pname;
    rev = "e4d64e643acb1cd6218fc61910ab6266d3da7573"; # HEAD @ version date
    hash = "sha256-ES8zZ9s6wGcqw60NoN4tZf/Dq/sBvl+UDYrXuOgfMxI=";
  };

  build-system = with python3Packages; [ setuptools ];
  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  meta = {
    description = "A pytest plugin that shortens test output with the full output stored in files";
    homepage = "https://git.libre-soc.org/?p=pytest-output-to-files.git;a=summary";
    license = lib.licenses.lgpl3Plus;
  };
}
