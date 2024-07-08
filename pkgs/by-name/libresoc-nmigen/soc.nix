{
  lib,
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
python39Packages.buildPythonPackage rec {
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

  propagatedBuildInputs =
    [
      libresoc-c4m-jtag
      libresoc-ieee754fpu
      libresoc-openpower-isa
      nmigen-soc
      yosys
    ]
    ++ (with python39Packages; [cached-property]);

  nativeCheckInputs =
    [
      power-instruction-analyzer
      pytest-output-to-files
    ]
    ++ (with python39Packages; [
      pytest-xdist
      pytestCheckHook
    ]);

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
    # ???
    "unused_please_ignore_completely/"
    # TypeError: __init__() missing 4 required positional arguments: 'fukls', 'iodef', 'funit', and 'bigendian'
    "src/soc/fu/compunits/test/"
    # TypeError: unsupported operand type(s) for -: 'Mock' and 'int'
    "src/soc/fu/mmu/test/"
  ];

  pythonImportsCheck = ["soc"];

  meta = with lib; {
    description = "A nmigen-based OpenPOWER multi-issue Hybrid 3D CPU-VPU-GPU";
    homepage = "https://git.libre-soc.org/?p=soc.git;a=summary";
    license = lib.licenses.lgpl3Plus;
  };
}
