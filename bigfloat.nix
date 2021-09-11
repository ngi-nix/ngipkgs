{ lib, buildPythonPackage, bigfloat, fetchPypi, gmp, mpfr }:

buildPythonPackage rec {
  pname = "bigfloat";
  version = "0.4.0";

  buildInputs = [ gmp mpfr ];

  src = fetchPypi {
    inherit pname version;
    sha256 = "WLlr3ocqylmJ0T2C66Os8qoblOIhF91yoWulkRsMDLg=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://pypi.org/project/bigfloat/";
    license = licenses.lgpl3Plus;
  };
}
