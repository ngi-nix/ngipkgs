{
  python39Packages,
  fetchPypi,
  mpfr,
}:
with python39Packages;
  buildPythonPackage rec {
    name = "bigfloat";
    pname = name;
    version = "0.4.0";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-WLlr3ocqylmJ0T2C66Os8qoblOIhF91yoWulkRsMDLg=";
    };

    propagatedBuildInputs = [mpfr six];
  }
