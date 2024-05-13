{
  lib,
  fetchFromLibresoc,
  python39Packages,
  symbiyosys,
  yices,
  nmigen,
  pytest-output-to-files,
}:
python39Packages.buildPythonPackage rec {
  pname = "libresoc-nmutil"; # Libre-SOC's bespoke fork
  version = "unstable-2024-03-31";

  src = fetchFromLibresoc {
    pname = "nmutil";
    rev = "4bf2f20bddc057df1597d14e0b990c0b9bdeb10e"; # HEAD @ version date
    hash = "sha256-8jXQGO4IeB6WjGtjuHO8UBh9n3ei7LukmRoXSbNJ1vM=";
  };

  propagatedNativeBuildInputs =
    [
      symbiyosys
      yices
    ]
    ++ (with python39Packages; [
      pyvcd
    ]);

  nativeCheckInputs =
    [
      nmigen
      symbiyosys
      yices
    ]
    ++ (with python39Packages; [
      pytestCheckHook
      pytest-xdist
      pytest-output-to-files
    ]);

  pythonImportsCheck = ["nmutil"];

  meta = {
    description = "A nmigen utility library";
    homepage = "https://git.libre-soc.org/?p=nmutil.git;a=summary";
    license = lib.licenses.lgpl3Plus;
  };
}
