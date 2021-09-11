{ lib, buildPythonPackage, fetchgit }:

buildPythonPackage {
  pname = "libresoc-openpower-isa";
  version = "unstable-2021-09-04";

  src = fetchgit {
    url = "https://git.libre-soc.org/git/openpower-isa.git";
    rev = "6e43a194f3d07ed5a8daa297187a32746c4c4d3c";
    sha256 = "0EekUouTQruTXGO5jlPJtqh0DOudghILy0nca5eaZz8=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://pypi.org/project/libresoc-openpower-isa/";
    license = licenses.lgpl3Plus;
  };
}
