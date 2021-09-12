{ version, src }:

{ lib, python, buildPythonPackage, nmigen-soc, nmigen, modgrammar }:

buildPythonPackage {
  pname = "libresoc-openpower-isa";
  inherit version src;

  propagatedBuildInputs = [ nmigen-soc nmigen modgrammar ];

  doCheck = false;

  pythonImportsCheck = [ "c4m.nmigen.jtag.tap" ];

  meta = with lib; {
    homepage = "https://pypi.org/project/libresoc-openpower-isa/";
    license = licenses.lgpl3Plus;
  };
}
