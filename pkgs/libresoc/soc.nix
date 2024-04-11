{
  python39Packages,
  fetchgit,
  yosys,
  libresoc-c4m-jtag,
  libresoc-ieee754fpu,
  libresoc-openpower-isa,
  nmigen-soc,
  power-instruction-analyzer,
  pytest-output-to-files,
}:
with python39Packages;
  buildPythonPackage {
    pname = "soc";
    version = "unstable-2024-03-31";

    src = fetchgit {
      url = "https://git.libre-soc.org/git/soc.git";
      sha256 = "sha256-yJshQYf8V0CB2vPCmWLlnxXMhi/sPXiLKzOn6cqgmxw=";
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
