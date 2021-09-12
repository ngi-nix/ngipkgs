{ lib, buildPythonPackage, fetchFromGitHub }:

buildPythonPackage rec {
  pname = "modgrammar";
  version = "unstable-2020-09-20";

  src = fetchFromGitHub {
    owner = "bloerwald";
    repo = "modgrammar";
    rev = "d363ad5a86584e560a8b03cbe11c0168d7610691";
    sha256 = "SO2qjfEVaJfgbA5HLJYwXlaeUzt5EFoljYQ2SsdDCbc=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://pypi.org/project/modgrammar/";
    # license = licenses.bsd; # FIXME: Which BSD?
  };
}
