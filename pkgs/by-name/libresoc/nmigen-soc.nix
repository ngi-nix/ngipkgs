{
  lib,
  python39Packages,
  fetchFromGitLab,
  nmigen,
}:
with python39Packages;
  buildPythonPackage rec {
    pname = "nmigen-soc";
    version = "unstable-2024-03-31";
    # python setup.py --version
    realVersion = "0.1.dev243+g${lib.substring 0 7 src.rev}";

    # NOTE(jleightcap): while libre-soc project does have local forks of nmigen* projects,
    # HEADs of repos are incompatible.
    # dev-env-setup implies that these forks are unused in build process, so using upstream.
    src = fetchFromGitLab {
      owner = "nmigen";
      repo = "nmigen-soc";
      hash = "sha256-RI481chXiD9kP/6vNLzYGOfcbwHH0Cvhk+CgloCY9JU=";
      rev = "fd2aaa336283cff2e46f489bf3897780cd217b8b"; # HEAD @ version date
    };

    nativeBuildInputs = [setuptools-scm];
    propagatedBuildInputs = [nmigen setuptools];

    preBuild = ''
      export SETUPTOOLS_SCM_PRETEND_VERSION="${realVersion}"
    '';

    nativeCheckInputs = [pytestCheckHook];
  }
