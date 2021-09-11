{ version }:

{ lib, buildPythonPackage, yosys, runCommand, c4m-jtag, nmigen-soc
, libresoc-ieee754fpu, libresoc-openpower-isa, python }:

let
  # If we use ../. as source, then any change to
  # any unrelated Nix file would cause a rebuild,
  # since the build would have access to it.
  src = runCommand "libresoc-soc-source" {} ''
    mkdir $out
    cp -r ${../src} -T $out/src
    cp -r ${../setup.py} -T $out/setup.py
    cp -r ${../README.md} -T $out/README.md
    cp -r ${../NEWS.txt} -T $out/NEWS.txt
  '';
in
buildPythonPackage {
  pname = "libresoc-soc";
  inherit version src;

  propagatedBuildInputs = [
    c4m-jtag nmigen-soc python libresoc-ieee754fpu libresoc-openpower-isa yosys
  ];

  doCheck = false;

  prePatch = ''
    rm -r src/soc/litex
  '';

  pythonImportsCheck = [ "soc" ];

  meta = with lib; {
    homepage = "https://libre-soc.org/";
    license = licenses.lgpl3Plus;
  };
}
