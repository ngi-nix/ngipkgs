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

    # TODO: upstream nixpkgs Amaranth package uses a patch for Python >3.8 compatibility in setuptools:
    # https://github.com/amaranth-lang/amaranth/commit/64771a065a280fa683c1e6692383bec4f59f20fa.patch
    # without this upgraded version, the C/C++ compiler used in tests via setuptools.distutils.ccompiler breaks.
    # Given the pre-fork nmigen release being used in Libre-SOC, this patch isn't directly portable to this package,
    # so disabling the test suite for now.
    doCheck = false;
  }
