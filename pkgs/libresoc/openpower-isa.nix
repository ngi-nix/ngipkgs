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

    patches = [
      # setup.py uses @git syntax for version specifiers, prevent setuptools from attempting to clone
      ./use-vendored-git-dependencies.patch
      # patch out hack to create empty directory in output build
      # see postInstall notes for complement
      ./remove-gitignore-check.patch
      # Makefile attempts to use recently-built binaries via $PATH, expose instead with a $(OPENPOWER) prefix
      # see postInstall notes for complement
      ./prefixed-openpower-isa-tools.patch
    ];

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

    postInstall =
      ''
        # complement of `remove-gitignore-check.patch`
        mkdir -p $out/${python39.sitePackages}/openpower/decoder/isa/generated

        # linker script vendored in test library
        cp ./src/openpower/simulator/memmap $out/${python39.sitePackages}/openpower/simulator/
      ''
      + (
        # this project's build steps do not map cleanly onto Nix's build stages.
        # setuptools builds the the `entry_points` into binaries that are used to codegen
        # directly into the source directory, which is then bundled into a wheel and installed.
        #
        # for Nix, there's a chicken-and-egg problem with this:
        # only once the package has been built can the codegen be run to... build the package from source.
        # as a result, the installPhase is overloaded to effectively double as the build phase,
        # so, the majority of build steps actually occur here, at the end:
        let
          codegen = writeShellApplication {
            name = "run-codegen";
            runtimeInputs = [gnumake pkgsCross.powernv.buildPackages.gcc];
            text = "make generate";
          };
        in ''
          # copy special-purpose python modules into path expected by codegen
          cp -rT ./openpower $out/${python39.sitePackages}/../openpower/

          # complement of `prefixed-openpower-isa-tools.patch`
          OPENPOWER=$out ${codegen}/bin/run-codegen

          # ...again now including codegen source
          cp -rT ./openpower $out/${python39.sitePackages}/../openpower/
        ''
      );
  }
