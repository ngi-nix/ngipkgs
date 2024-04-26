{ lib, buildPythonPackage, libresoc-nmutil, bigfloat, fetchgit }:

buildPythonPackage {
  pname = "libresoc-ieee754fpu";
  version = "unstable-2021-06-05";

  src = fetchgit {
    url = "https://git.libre-soc.org/git/ieee754fpu.git";
    rev = "c62fa3a7ee95832587d7725729dcdb9a002ae015";
    sha256 = "wbr1vGFzUlUtBT6IcRsykADYeksiVoq/LacU/dbRQ0o=";
  };

  propagatedBuildInputs = [ libresoc-nmutil bigfloat ];

  doCheck = false;

  prePatch = ''
    touch ./src/ieee754/part/__init__.py
  '';

  pythonImportsCheck = [ "ieee754.part" ];

  meta = with lib; {
    homepage = "https://pypi.org/project/libresoc-ieee754fpu/";
    license = licenses.lgpl3Plus;
  };
}
