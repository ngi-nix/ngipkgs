{
  python39,
  python39Packages,
  fetchgit,
  pkgsCross,
  writeShellApplication,
  gnumake,
  pytest-output-to-files,
  libresoc-pyelftools,
  nmigen,
  nmutil,
  mdis,
}:
with python39Packages;
  buildPythonPackage rec {
    name = "libresoc-openpower-isa";
    version = "unstable-2024-03-31";

    src = fetchgit {
      url = "https://git.libre-soc.org/git/openpower-isa.git";
      sha256 = "sha256-OKUb3BmVEZD2iRV8sbNEEA7ANJImWX8FEj06o5+HQwU=";
      rev = "3cb597b99d414dbdb35336eb3734b5d46edd597f"; # HEAD @ version date
    };
    propagatedNativeBuildInputs = [
      astor
      cached-property
      cffi
      libresoc-pyelftools
      mdis
      nmigen
      nmutil
      pkgsCross.powernv.buildPackages.gcc
      ply
      pygdbmi
    ];
  }
