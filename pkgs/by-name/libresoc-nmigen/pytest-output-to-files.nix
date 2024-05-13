{
  lib,
  fetchFromLibresoc,
  python39Packages,
}:
python39Packages.buildPythonPackage rec {
  pname = "pytest-output-to-files";
  version = "unstable-2024-03-31";

  src = fetchFromLibresoc {
    inherit pname;
    rev = "e4d64e643acb1cd6218fc61910ab6266d3da7573"; # HEAD @ version date
    hash = "sha256-ES8zZ9s6wGcqw60NoN4tZf/Dq/sBvl+UDYrXuOgfMxI=";
  };

  nativeCheckInputs = with python39Packages; [pytestCheckHook];

  meta = {
    description = "A pytest plugin that shortens test output with the full output stored in files";
    homepage = "https://git.libre-soc.org/?p=pytest-output-to-files.git;a=summary";
    license = lib.licenses.lgpl3Plus;
  };
}
