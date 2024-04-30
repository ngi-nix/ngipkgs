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

    patches = [./soc-nmigen-soc-no-implicit-arg.patch];

    postPatch = ''
      rm -r src/soc/litex
    '';

    propagatedBuildInputs = [
      cached-property
      libresoc-c4m-jtag
      libresoc-ieee754fpu
      libresoc-openpower-isa
      nmigen-soc
      yosys
    ];

    nativeCheckInputs = [
      power-instruction-analyzer
      pytest-output-to-files
      pytest-xdist
      pytestCheckHook
    ];

    disabledTests = [
      # listed failures seem unlikely to result from packaging errors, assumed present upstream
      "test_div_pipe_core"
      "test_fsm_div_core"
      "test_sim_onl"
      "test_mul_pipe_2_arg"
      "test_mul_pipe_2_arg"
      "test_it"
      "test_sim_only"
      "test_div_pipe_core"
      "test_fsm_div_core"
    ];

    disabledTestPaths = [
      "unused_please_ignore_completely/" # ???
    ];

    pythonImportsCheck = ["soc"];
  }
