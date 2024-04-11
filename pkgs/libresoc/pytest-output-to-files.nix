{
  fetchgit,
  python39Packages,
}:
with python39Packages;
  buildPythonPackage {
    name = "pytest-output-to-files";
    version = "unstable-2024-03-31";

    src = fetchgit {
      url = "https://git.libre-soc.org/git/pytest-output-to-files.git";
      sha256 = "sha256-ES8zZ9s6wGcqw60NoN4tZf/Dq/sBvl+UDYrXuOgfMxI=";
    };

    nativeCheckInputs = [pytestCheckHook];
  }
