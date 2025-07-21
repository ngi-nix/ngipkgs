{
  lib,
  fetchFromLibresoc,
  python3Packages,
  symbiyosys,
  yices,
  nmigen,
  pytest-output-to-files,
}:
python3Packages.buildPythonPackage {
  pname = "libresoc-nmutil"; # Libre-SOC's bespoke fork
  version = "0-unstable-2022-11-16";
  pyproject = true;

  src = fetchFromLibresoc {
    pname = "nmutil";
    rev = "4bf2f20bddc057df1597d14e0b990c0b9bdeb10e"; # HEAD @ version date
    hash = "sha256-8jXQGO4IeB6WjGtjuHO8UBh9n3ei7LukmRoXSbNJ1vM=";
  };

  # https://github.com/YosysHQ/yosys/pull/4704
  postPatch = ''
    sed -i "s/read_ilang/read_rtlil/g" build/lib/nmutil/*.py src/nmutil/*.py
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  propagatedNativeBuildInputs = [
    symbiyosys
    yices
  ]
  ++ (with python3Packages; [
    pyvcd
  ]);

  nativeCheckInputs = [
    nmigen
    symbiyosys
    yices
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    pytest-xdist
    pytest-output-to-files
  ]);

  pythonImportsCheck = [ "nmutil" ];

  meta = {
    description = "A nmigen utility library";
    homepage = "https://git.libre-soc.org/?p=nmutil.git;a=summary";
    license = lib.licenses.lgpl3Plus;
  };
}
