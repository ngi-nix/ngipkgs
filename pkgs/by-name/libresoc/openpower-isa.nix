{ lib, python, buildPythonPackage, fetchgit, libresoc-nmutil, astor, nmigen, ply, pygdbmi }:

buildPythonPackage {
  pname = "libresoc-openpower-isa";
  version = "unstable-2021-09-04";

  src = fetchgit {
    url = "https://git.libre-soc.org/git/openpower-isa.git";
    rev = "6e43a194f3d07ed5a8daa297187a32746c4c4d3c";
    sha256 = "0EekUouTQruTXGO5jlPJtqh0DOudghILy0nca5eaZz8=";
  };

  propagatedBuildInputs = [ libresoc-nmutil astor nmigen ply pygdbmi ];

  doCheck = false;

  prePatch = ''
    touch ./src/openpower/sv/__init__.py # TODO: fix upstream
  '';

  postInstall = ''
    cp -rT ./openpower $out/${python.sitePackages}/../openpower/
  '';

  pythonImportsCheck = [ "openpower.decoder.power_decoder2" "openpower" ];

  meta = with lib; {
    homepage = "https://pypi.org/project/libresoc-openpower-isa/";
    license = licenses.lgpl3Plus;
  };
}
