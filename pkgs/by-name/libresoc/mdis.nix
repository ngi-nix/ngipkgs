{
  python39Packages,
  fetchPypi,
}:
with python39Packages;
  buildPythonPackage rec {
    pname = "mdis";
    version = "0.5.1";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-gvXtP8NO5XPDAs0XMbGknG79FscN/7lxqmF1kg3nhxg=";
    };
  }
