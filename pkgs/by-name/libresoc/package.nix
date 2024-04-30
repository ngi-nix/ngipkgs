{
  callPackage,
  fetchgit,
}: let
  fetchFromLibresoc = {
    pname,
    hash,
    rev,
    ...
  }:
    fetchgit {
      url = "https://github.com/Libre-SOC-mirrors/${pname}.git";
      inherit rev hash;
    };

  # JTAG debugging
  libresoc-c4m-jtag = callPackage ./libresoc-c4m-jtag.nix {inherit fetchFromLibresoc nmigen nmigen-soc;};
  # floating point implementation
  libresoc-ieee754fpu = callPackage ./ieee754fpu.nix {inherit nmutil nmigen pytest-output-to-files sfpy bigfloat;};
  # openpower-isa definition
  libresoc-openpower-isa = callPackage ./openpower-isa.nix {
    inherit
      libresoc-pyelftools
      mdis
      nmigen
      nmutil
      pytest-output-to-files
      ;
  };
  # libresoc's fork of pyelftools, few commits have diverged from pyelftools packaged by nixpkgs
  libresoc-pyelftools = callPackage ./libresoc-pyelftools.nix {};
  # python software floating point implementations
  sfpy = callPackage ./sfpy.nix {};
  bigfloat = callPackage ./bigfloat.nix {};
  mdis = callPackage ./mdis.nix {};
  # libresoc's nmigen fork has been renamed to https://github.com/amaranth-lang/amaranth
  # amaranth is packaged in nixpkgs but we can't just override a few of the attributes the way we did for pyelftools,
  # because the names are different, so much of this is copied from the amaranth build recipe
  nmigen = callPackage ./nmigen.nix {};
  # libresoc's nmigen-soc fork has been renamed to https://github.com/amaranth-lang/amaranth-soc.
  # suffers from the same rename issue as the previous commit with renaming issue as nmigen/amaranth
  nmigen-soc = callPackage ./nmigen-soc.nix {inherit nmigen;};
  # libresoc's nmutil fork, used for differential testing
  nmutil = callPackage ./nmutil.nix {inherit nmigen pytest-output-to-files;};
  # library for running pin multiplexers
  pinmux = callPackage ./pinmux.nix {};
  # libresoc's PowerPC emulator
  power-instruction-analyzer = callPackage ./power-instruction-analyzer.nix {};
  # libresoc's test harness
  pytest-output-to-files = callPackage ./pytest-output-to-files.nix {};
  # SoC target circuit synthesized to nmigen(-soc)
  soc = callPackage ./soc.nix {
    inherit
      libresoc-c4m-jtag
      libresoc-ieee754fpu
      libresoc-openpower-isa
      nmigen-soc
      power-instruction-analyzer
      pytest-output-to-files
      ;
  };
in
  # SoC synthesized to Verilog
  callPackage ./verilog.nix {
    inherit
      pinmux
      soc
      ;
  }
