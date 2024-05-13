{
  lib,
  python39Packages,
  fetchPypi,
}:
python39Packages.buildPythonPackage rec {
  pname = "mdis";
  version = "0.5.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-gvXtP8NO5XPDAs0XMbGknG79FscN/7lxqmF1kg3nhxg=";
  };

  meta = {
    description = "Python dispatching library";
    homepage = "https://git.libre-soc.org/?p=mdis.git";
    license = lib.licenses.bsd3;
  };
}
