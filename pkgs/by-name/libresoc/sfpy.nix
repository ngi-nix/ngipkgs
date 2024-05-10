{
  python39Packages,
  fetchPypi,
}:
python39Packages.buildPythonPackage rec {
  name = "sfpy";
  pname = name;
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ueZkPbxR0MCR+2oM+ZhhKt9sRb6Oppn+evU6u5HRlMo=";
  };
}
