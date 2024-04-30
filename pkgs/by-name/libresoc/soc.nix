{
  python39Packages,
  fetchFromLibresoc,
  yosys,
  libresoc-c4m-jtag,
  libresoc-ieee754fpu,
  libresoc-openpower-isa,
  nmigen-soc,
  power-instruction-analyzer,
  pytest-output-to-files,
}:
with python39Packages;
  buildPythonPackage rec {
    name = "soc";
    pname = name;
    version = "unstable-2024-03-31";

    src = fetchFromLibresoc {
      inherit pname;
      rev = "2a66fe18cd77dd5533c65930d1b241cf6faac455"; # HEAD @ version date
      hash = "sha256-yJshQYf8V0CB2vPCmWLlnxXMhi/sPXiLKzOn6cqgmxw=";
      fetchSubmodules = false;
    };

    propagatedBuildInputs = [
      cached-property
      libresoc-c4m-jtag
      libresoc-ieee754fpu
      libresoc-openpower-isa
      nmigen-soc
      yosys
    ];
  }
