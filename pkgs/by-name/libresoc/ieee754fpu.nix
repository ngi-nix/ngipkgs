{
  python39Packages,
  fetchFromLibresoc,
  bigfloat,
  sfpy,
  symbiyosys,
  nmutil,
  nmigen,
  pytest-output-to-files,
}:
with python39Packages;
  buildPythonPackage {
    pname = "libresoc-ieee754fpu";
    version = "unstable-2024-03-31";

    src = fetchFromLibresoc {
      inherit pname;
      hash = "sha256-Ghbvg2Y4YlmxVEa3EtcvEVai4hC4VU4q+XIQh4pQ7+c=";
      rev = "829dfbc53ba38ec17bc544cb0b862e73cee223db"; # HEAD @ version date
    };

    prePatch = ''
      touch ./src/ieee754/part{,_ass,_cat,_repl}/__init__.py
    '';

    propagatedBuildInputs = [nmutil];

    nativeCheckInputs = [pytestCheckHook pytest-xdist pytest-output-to-files nmigen symbiyosys];

    # TODO(jleightcap): all tests pass except formal methods,
    # > ERROR: Module `\U$$0' referenced in module `\top' in cell `$15' is a blackbox/whitebox module.
    # might be an issue with symbiyosys version?
    doCheck = false;

    pythonImportsCheck = ["ieee754.part"];
  }
