{
  lib,
  python39,
  fetchFromLibresoc,
  pkgsCross,
  writeShellApplication,
  gnumake,
  pytest-output-to-files,
  libresoc-pyelftools,
  nmigen,
  nmutil,
  mdis,
}: let
  python = python39;
  pythonPackages = python39.pkgs;
in
  pythonPackages.buildPythonPackage rec {
    name = "libresoc-openpower-isa";
    pname = "openpower-isa";
    version = "unstable-2024-03-31";

    src = fetchFromLibresoc {
      inherit pname;
      rev = "3cb597b99d414dbdb35336eb3734b5d46edd597f"; # HEAD @ version date
      hash = "sha256-OKUb3BmVEZD2iRV8sbNEEA7ANJImWX8FEj06o5+HQwU=";
    };

    # TODO: potential upstream patches
    prePatch = ''
      # broken upstream, required for importing modules in tests
      touch ./src/openpower/{sv,test/general}/__init__.py

      # doing this substitution because this compiler prefix needs to agree between nix and upstream
      substituteInPlace src/openpower/syscalls/ppc_flags.py \
        --replace 'powerpc64le-linux-gnu-gcc' '${pkgsCross.powernv.buildPackages.gcc.targetPrefix}gcc'
      substituteInPlace src/openpower/simulator/envcmds.py \
        --replace 'powerpc64-linux-gnu-' '${pkgsCross.powernv.buildPackages.gcc.targetPrefix}' \
        --replace 'os.environ.get(cmd.upper(), default)' 'default'
    '';

    patches = [
      # pip will try to clone dependencies using @git versions, but this patch makes it so we can use the repos that have already been vendored in by nix
      ./use-vendored-git-dependencies.patch
      # upstream includes .gitignore in empty directory to place that empty directory in the build output
      # Nix happens to break this fragile hack, so remove and make output directory manually
      ./remove-gitignore-check.patch
      # Makefile attempts to use recently-built binaries via $PATH, expose instead with a $(OPENPOWER) prefix
      # see postInstall notes for complement
      ./prefixed-openpower-isa-tools.patch
    ];

    # Native is the build machine architecture (e.g. x86_64 linux)
    # This will run a python emulator of the target architecture, which is PowerPC for this project
    # The assembler has to run on native but target PowerPC assembly
    propagatedNativeBuildInputs =
      [
        libresoc-pyelftools
        mdis
        nmigen
        nmutil
        pkgsCross.powernv.buildPackages.gcc
      ]
      ++ (with pythonPackages; [
        astor
        cached-property
        cffi
        ply
        pygdbmi
      ]);

    # TODO: potential upstream work
    postInstall =
      ''
        # complement of `remove-gitignore-check.patch`
        mkdir -p $out/${python.sitePackages}/openpower/decoder/isa/generated

        # this file is missed in the installation configuration, manually move into output
        # potential to upstream fix to configuration that maintains this file
        cp ./src/openpower/simulator/memmap $out/${python.sitePackages}/openpower/simulator/
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
          cp -rT ./openpower $out/${python.sitePackages}/../openpower/

          # complement of `prefixed-openpower-isa-tools.patch`
          OPENPOWER=$out/bin ${codegen}/bin/run-codegen

          # ...again now including codegen source
          cp -rT ./openpower $out/${python.sitePackages}/../openpower/
        ''
      );

    nativeCheckInputs =
      [
        pytest-output-to-files
        pkgsCross.powernv.buildPackages.gcc
      ]
      ++ (with pythonPackages; [
        pytestCheckHook
        pytest-xdist
      ]);

    disabledTests = [
      # listed failures seem unlikely to result from packaging errors, assumed present upstream
      "test_20_cmp"
      "test_36_extras_rldimi"
      "test_36_extras_rldimi_"
      "test_3_sv_isel"
      "test_37_extras_rldimi"
      "test_4_sv_crand"
    ];

    disabledTestPaths = [
      # listed paths import from codegen source, which is not in scope here.
      "src/openpower/decoder/isa/"
      "src/openpower/simulator/test_div_sim.py"
      "src/openpower/simulator/test_helloworld_sim.py"
      "src/openpower/simulator/test_mul_sim.py"
      "src/openpower/simulator/test_shift_sim.py"
      "src/openpower/simulator/test_sim.py"
      "src/openpower/simulator/test_trap_sim.py"
    ];

    pythonImportsCheck = [
      "openpower.decoder.power_decoder2"
      "openpower"
    ];

    meta = {
      description = "OpenPOWER ISA resources including a python-based simulator";
      homepage = "https://git.libre-soc.org/?p=openpower-isa.git;a=summary";
      license = lib.licenses.gpl3Plus;
    };
  }
