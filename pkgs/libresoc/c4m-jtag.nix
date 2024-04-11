{
  lib,
  fetchgit,
  python39,
  python39Packages,
  nmigen-soc,
  nmigen,
}:
python39Packages.buildPythonPackage rec {
  pname = "c4m-jtag";
  version = "unstable-2024-03-31";
  realVersion = "0.3.dev243+g${lib.substring 0 7 src.rev}";

  src = fetchgit {
    url = "https://git.libre-soc.org/git/c4m-jtag.git";
    sha256 = "sha256-0yF/yqcknCq1fre5pnKux4V7guu2oDa6duPO9mU46n8=3";
  };

  prePatch = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${realVersion}"
  '';

  nativeBuildInputs = with python39Packages; [setuptools-scm];
  propagatedBuildInputs = [nmigen-soc];

  nativeCheckInputs = with python39Packages; [nose];
  checkPhase = "nosetests";

  pythonImportsCheck = ["c4m.nmigen.jtag.tap"];
}
