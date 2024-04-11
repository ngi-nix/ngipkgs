{
  lib,
  fetchFromLibresoc,
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

    src = fetchFromLibresoc {
      inherit pname;
      rev = "4bf2f20bddc057df1597d14e0b990c0b9bdeb10e"; # HEAD @ version date
      hash = "sha256-8jXQGO4IeB6WjGtjuHO8UBh9n3ei7LukmRoXSbNJ1vM=";
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
