{
  lib,
  python3Packages,
  fetchFromGitHub,
  mpfr,
}:
python3Packages.buildPythonPackage rec {
  pname = "bigfloat";
  version = "0.4.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mdickinson";
    repo = "bigfloat";
    tag = "v${version}";
    hash = "sha256-HgbwA0YksF/LDiD8WrcQZKilU6J94zSkgIyR+UUf+do=";
  };

  build-system = with python3Packages; [
    cython
    setuptools
  ];

  propagatedBuildInputs = [ mpfr ] ++ (with python3Packages; [ six ]);

  meta = {
    description = "Arbitrary-precision correctly-rounded floating-point arithmetic, via MPFR.";
    homepage = "http://github.com/mdickinson/bigfloat";
    license = lib.licenses.lgpl3Plus;
  };
}
