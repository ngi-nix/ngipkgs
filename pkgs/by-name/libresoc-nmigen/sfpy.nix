{
  lib,
  python39Packages,
  fetchFromGitHub,
}:
python39Packages.buildPythonPackage rec {
  pname = "sfpy";
  version = "0.6.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "billzorn";
    repo = "sfpy";
    tag = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-soY7Mqp5OlELXVJGGVJRkWskqsP4pcGcdtkZw436Zho=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "make pic" "make"
  '';

  build-system = with python39Packages; [
    cython_0
    setuptools
  ];

  preConfigure = ''
    make lib
    make cython
  '';

  meta = {
    description = "soft-float python bindings (berkeley softfloat-3, posit library)";
    homepage = "https://git.libre-soc.org/?p=sfpy.git;a=summary";
    license = lib.licenses.mit;
  };
}
