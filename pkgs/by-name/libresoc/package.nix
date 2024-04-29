{
  callPackage,
  fetchgit,
}: let
  fetchFromLibresoc = {
    pname,
    hash,
    rev,
    fetchSubmodules ? true,
  }:
    fetchgit {
      url = "https://github.com/Libre-SOC-mirrors/${pname}.git";
      inherit rev hash fetchSubmodules;
    };

  libresoc-c4m-jtag = callPackage ./libresoc-c4m-jtag.nix {inherit fetchFromLibresoc nmigen nmigen-soc;};
  libresoc-ieee754fpu = callPackage ./ieee754fpu.nix {inherit fetchFromLibresoc nmutil nmigen pytest-output-to-files sfpy bigfloat;};
  libresoc-openpower-isa = callPackage ./openpower-isa.nix {
    inherit
      fetchFromLibresoc
      libresoc-pyelftools
      mdis
      nmigen
      nmutil
      pytest-output-to-files
      ;
  };
  libresoc-pyelftools = callPackage ./libresoc-pyelftools.nix {};
  sfpy = callPackage ./sfpy.nix {};
  bigfloat = callPackage ./bigfloat.nix {};
  mdis = callPackage ./mdis.nix {};
  nmigen = callPackage ./nmigen.nix {};
  nmigen-soc = callPackage ./nmigen-soc.nix {inherit nmigen;};
  nmutil = callPackage ./nmutil.nix {inherit fetchFromLibresoc nmigen pytest-output-to-files;};
  pinmux = callPackage ./pinmux.nix {inherit fetchFromLibresoc;};
  power-instruction-analyzer = callPackage ./power-instruction-analyzer.nix {inherit fetchFromLibresoc;};
  pytest-output-to-files = callPackage ./pytest-output-to-files.nix {inherit fetchFromLibresoc;};
  soc = callPackage ./soc.nix {
    inherit
      fetchFromLibresoc
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
