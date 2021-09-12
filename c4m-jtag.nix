{ version, src }:

{ lib, python, buildPythonPackage, nmigen-soc, nmigen, modgrammar, setuptools-scm }:

buildPythonPackage {
  pname = "c4m-jtag";
  inherit src;
  version = "2.17";

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ nmigen-soc nmigen modgrammar ];

  doCheck = false;

  pythonImportsCheck = [ "c4m.nmigen.jtag.tap" ];

  prePatch = ''
    sed -i -e 's/use_scm_version=scm_version..,//g' setup.py
  '';

  meta = with lib; {
    homepage = "https://pypi.org/project/libresoc-openpower-isa/";
    license = licenses.lgpl3Plus;
  };
}
