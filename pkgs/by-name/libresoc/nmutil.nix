{ lib, buildPythonPackage, bigfloat, fetchgit, pyvcd }:

buildPythonPackage {
  pname = "libresoc-nmutil";
  version = "unstable-2021-08-24";

  propagatedBuildInputs = [ pyvcd ];

  src = fetchgit {
    url = "https://git.libre-soc.org/git/nmutil.git";
    rev = "efda080db6978d249a23003bec734f1cc07de329";
    sha256 = "nTgUiZc4CC0VoUND29kHSIyMlP9IB3oZfehutoNK07w=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://pypi.org/project/libresoc-ieee754fpu/";
    license = licenses.lgpl3Plus;
  };
}
