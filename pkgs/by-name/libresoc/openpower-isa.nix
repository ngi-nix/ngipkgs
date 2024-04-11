{
  python39,
  python39Packages,
  fetchFromLibresoc,
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

    src = fetchFromLibresoc {
      inherit pname;
      rev = "3cb597b99d414dbdb35336eb3734b5d46edd597f"; # HEAD @ version date
      sha256 = "sha256-OKUb3BmVEZD2iRV8sbNEEA7ANJImWX8FEj06o5+HQwU=";
    };

    prePatch = ''
      # broken upstream, required for importing modules in tests
      touch ./src/openpower/{sv,test/general}/__init__.py

      # ignore $CC/$AS/etc environment variables and update hard-coded prefixes with pkgsCross compiler (powerpc64le-unknown-linux-gnu-gcc)
      substituteInPlace src/openpower/syscalls/ppc_flags.py \
        --replace 'powerpc64le-linux-gnu-gcc' '${pkgsCross.powernv.buildPackages.gcc.targetPrefix}gcc'
      substituteInPlace src/openpower/simulator/envcmds.py \
        --replace 'powerpc64-linux-gnu-' '${pkgsCross.powernv.buildPackages.gcc.targetPrefix}' \
        --replace 'os.environ.get(cmd.upper(), default)' 'default'
    '';

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
