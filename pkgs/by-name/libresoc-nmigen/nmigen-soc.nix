{
  lib,
  python39Packages,
  fetchFromGitLab,
  nmigen,
}:
python39Packages.buildPythonPackage rec {
  pname = "nmigen-soc";
  version = "unstable-2024-03-31";
  # python setup.py --version
  realVersion = "0.1.dev243+g${lib.substring 0 7 src.rev}";

  # NOTE(jleightcap): libresoc's nmigen-soc fork has been renamed to https://github.com/amaranth-lang/amaranth-soc.
  # suffers from the same rename issue as the previous commit with renaming issue as nmigen/amaranth
  # NOTE(jleightcap): while libre-soc project does have local forks of nmigen* projects,
  # HEADs of repos are incompatible.
  # dev-env-setup implies that these forks are unused in build process, so using upstream.
  src = fetchFromGitLab {
    owner = "nmigen";
    repo = "nmigen-soc";
    hash = "sha256-RI481chXiD9kP/6vNLzYGOfcbwHH0Cvhk+CgloCY9JU=";
    rev = "fd2aaa336283cff2e46f489bf3897780cd217b8b"; # HEAD @ version date
  };

  nativeBuildInputs = with python39Packages; [setuptools-scm];
  propagatedBuildInputs = with python39Packages; [nmigen setuptools];

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${realVersion}"
  '';

  nativeCheckInputs = with python39Packages; [pytestCheckHook];

  meta = {
    description = "Python toolbox for building complex digital hardware";
    license = lib.licenses.bsd3;
    homepage = "https://git.libre-soc.org/?p=nmigen.git;a=summary";
  };
}
