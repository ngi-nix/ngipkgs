{
  lib,
  python3Packages,
  fetchPypi,
}:
python3Packages.buildPythonPackage rec {
  pname = "mdis";
  version = "0.5.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-gvXtP8NO5XPDAs0XMbGknG79FscN/7lxqmF1kg3nhxg=";
  };

  build-system = with python3Packages; [ setuptools ];

  meta = {
    description = "Python dispatching library";
    homepage = "https://git.libre-soc.org/?p=mdis.git";
    license = lib.licenses.bsd3;
  };
}
