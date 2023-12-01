{
  python3,
  lib,
  fetchPypi,
}: let
  inherit
    (lib)
    licenses
    ;

  inherit
    (python3.pkgs)
    buildPythonPackage
    ;
in
  buildPythonPackage rec {
    pname = "euclid3";
    version = "0.01";
    format = "setuptools";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-JbgnpXrb/Zo/qGJeQ6vD6Qf2HeYiND5+U4SC75tG/Qs=";
    };

    pythonImportsCheck = [
      "euclid3"
    ];

    meta = {
      description = "2D and 3D vector, matrix, quaternion and geometry module.";
      homepage = "http://code.google.com/p/pyeuclid/";
      license = licenses.lgpl21Plus;
    };
  }
