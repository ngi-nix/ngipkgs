{
  lib,
  python39Packages,
  fetchPypi,
  mpfr,
}:
python39Packages.buildPythonPackage rec {
  pname = "bigfloat";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WLlr3ocqylmJ0T2C66Os8qoblOIhF91yoWulkRsMDLg=";
  };

  propagatedBuildInputs = [mpfr] ++ (with python39Packages; [six]);

  meta = {
    description = "Arbitrary-precision correctly-rounded floating-point arithmetic, via MPFR.";
    homepage = "http://github.com/mdickinson/bigfloat";
    license = lib.licenses.lgpl3;
  };
}
