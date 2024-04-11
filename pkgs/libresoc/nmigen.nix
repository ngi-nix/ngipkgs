{
  lib,
  fetchFromGitLab,
  git,
  python39Packages,
  symbiyosys,
  yices,
  yosys,
}:
with python39Packages;
  buildPythonPackage rec {
    pname = "nmigen";
    version = "unstable-2024-03-31";
    realVersion = "0.3.dev243+g${lib.substring 0 7 src.rev}";

    src = fetchFromGitLab {
      owner = "nmigen";
      repo = "nmigen";
      hash = "sha256-tpcA+FFHhm4gF37Z+rB/uZopSRtAtNxU8j5IXnSGeCg=";
      rev = "29dec30f628356828aa2aa2b91ce205a570d664e"; # HEAD @ version date
    };

    preBuild = ''
      export SETUPTOOLS_SCM_PRETEND_VERSION="${realVersion}"
    '';

    nativeBuildInputs = [git setuptools-scm];

    propagatedBuildInputs =
      [
        jinja2
        pyvcd
        yosys
      ]
      ++ lib.optional (pythonOlder "3.9") importlib-resources
      ++ lib.optional (pythonOlder "3.8") importlib-metadata;

    nativeCheckInputs = [
      pytestCheckHook
      symbiyosys
      yices
      yosys
    ];

    # nmigen wraps C/C++ compiler with setuptools.distutils.ccompiler
    # requires manual patching for compatibiility with this version of setuptools
    # https://github.com/NixOS/nixpkgs/pull/199974
    doCheck = false;
  }
