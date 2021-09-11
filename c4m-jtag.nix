{ version, src }:

{ lib, python, buildPythonPackage, nmigen-soc, nmigen, modgrammar, setuptools-scm }:

buildPythonPackage {
  pname = "c4m-jtag";
  inherit src version;

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ nmigen-soc nmigen modgrammar ];

  doCheck = false;

  pythonImportsCheck = [ "c4m.nmigen.jtag.tap" ];

  prePatch = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION=${version}
  '';

  meta = with lib; {
    homepage = "https://pypi.org/project/libresoc-openpower-isa/";
    license = licenses.lgpl3Plus;
  };
}
