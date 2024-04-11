{
  lib,
  fetchgit,
  python39Packages,
  symbiyosys,
  yices,
  nmigen,
  pytest-output-to-files,
}:
with python39Packages;
  buildPythonPackage {
    pname = "libresoc-nmutil";
    version = "unstable-2024-03-31";

    src = fetchgit {
      url = "https://git.libre-soc.org/git/nmutil.git";
      sha256 = "sha256-8jXQGO4IeB6WjGtjuHO8UBh9n3ei7LukmRoXSbNJ1vM=";
    };

    propagatedNativeBuildInputs = [
      pyvcd
      symbiyosys
      yices
    ];

    nativeCheckInputs = [
      nmigen
      symbiyosys
      yices
      pytestCheckHook
      pytest-xdist
      pytest-output-to-files
    ];

    pythonImportsCheck = ["nmutil"];
  }
