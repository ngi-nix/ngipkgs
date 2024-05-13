{
  lib,
  python39Packages,
  fetchPypi,
}:
python39Packages.buildPythonPackage rec {
  pname = "sfpy";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ueZkPbxR0MCR+2oM+ZhhKt9sRb6Oppn+evU6u5HRlMo=";
  };

  meta = {
    description = "soft-float python bindings (berkeley softfloat-3, posit library)";
    homepage = "https://git.libre-soc.org/?p=sfpy.git;a=summary";
    license = lib.licenses.mit;
  };
}
