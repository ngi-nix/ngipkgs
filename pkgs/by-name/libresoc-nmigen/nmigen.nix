{
  lib,
  fetchFromGitLab,
  git,
  python3Packages,
  symbiyosys,
  yices,
  yosys,
}:
python3Packages.buildPythonPackage rec {
  pname = "nmigen";
  version = "0-unstable-2022-09-27";
  realVersion = "0.3.dev243+g${lib.substring 0 7 src.rev}";
  pyproject = true;

  # libresoc's nmigen fork has been renamed to https://github.com/amaranth-lang/amaranth
  # amaranth is packaged in nixpkgs but we can't just override a few of the attributes the way we did for pyelftools,
  # because the names are different, so much of this is copied from the amaranth build recipe
  src = fetchFromGitLab {
    owner = "nmigen";
    repo = "nmigen";
    hash = "sha256-tpcA+FFHhm4gF37Z+rB/uZopSRtAtNxU8j5IXnSGeCg=";
    rev = "29dec30f628356828aa2aa2b91ce205a570d664e"; # HEAD @ version date
  };

  # https://github.com/YosysHQ/yosys/pull/4704
  postPatch = ''
    sed -i "s/read_ilang/read_rtlil/g" nmigen/back/*.py nmigen/vendor/*.py tests/*.py
  '';

  preBuild = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${realVersion}"
  '';

  nativeBuildInputs = [ git ] ++ (with python3Packages; [ setuptools-scm ]);

  propagatedBuildInputs = [
    yosys
  ]
  ++ (with python3Packages; [
    jinja2
    pyvcd
  ]);

  nativeCheckInputs = [
    symbiyosys
    yices
    yosys
  ]
  ++ (with python3Packages; [ pytestCheckHook ]);

  pythonRelaxDeps = [
    "pyvcd"
  ];

  # TODO: upstream nixpkgs Amaranth package uses a patch for Python >3.8 compatibility in setuptools:
  # https://github.com/amaranth-lang/amaranth/commit/64771a065a280fa683c1e6692383bec4f59f20fa.patch
  # without this upgraded version, the C/C++ compiler used in tests via setuptools.distutils.ccompiler breaks.
  # Given the pre-fork nmigen release being used in Libre-SOC, this patch isn't directly portable to this package,
  # so disabling the test suite for now.
  doCheck = false;

  meta = {
    description = "Python toolbox for building complex digital hardware";
    homepage = "https://git.libre-soc.org/?p=nmigen.git;a=summary";
    license = lib.licenses.mit;
  };
}
