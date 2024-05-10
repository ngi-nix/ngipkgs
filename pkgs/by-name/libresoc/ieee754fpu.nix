{
  python39Packages,
  fetchFromLibresoc,
  bigfloat,
  sfpy,
  symbiyosys,
  nmutil,
  nmigen,
  pytest-output-to-files,
}:
with python39Packages;
  buildPythonPackage {
    pname = "libresoc-ieee754fpu";
    version = "unstable-2024-03-31";

    src = fetchFromLibresoc {
      inherit pname;
      hash = "sha256-Ghbvg2Y4YlmxVEa3EtcvEVai4hC4VU4q+XIQh4pQ7+c=";
      rev = "829dfbc53ba38ec17bc544cb0b862e73cee223db"; # HEAD @ version date
    };

    prePatch = ''
      touch ./src/ieee754/part{,_ass,_cat,_repl}/__init__.py
    '';

    propagatedBuildInputs = [nmutil];

    nativeCheckInputs = [pytestCheckHook pytest-xdist pytest-output-to-files nmigen symbiyosys sfpy bigfloat];

    disabledTests = [
      "test_fadd_f16_rna_formal"
      "test_fadd_f16_rne_formal"
      "test_fadd_f16_rtn_formal"
      "test_fadd_f16_rton_formal"
      "test_fadd_f16_rtop_formal"
      "test_fadd_f16_rtp_formal"
      "test_fadd_f16_rtz_formal"
      "test_fmadd_f8_rna_formal"
      "test_fmadd_f8_rne_formal"
      "test_fmadd_f8_rtn_formal"
      "test_fmadd_f8_rton_formal"
      "test_fmadd_f8_rtop_formal"
      "test_fmadd_f8_rtp_formal"
      "test_fmadd_f8_rtz_formal"
      "test_fmsub_f8_rna_formal"
      "test_fmsub_f8_rne_formal"
      "test_fmsub_f8_rtn_formal"
      "test_fmsub_f8_rton_formal"
      "test_fmsub_f8_rtop_formal"
      "test_fmsub_f8_rtp_formal"
      "test_fmsub_f8_rtz_formal"
      "test_fnmadd_f8_rna_formal"
      "test_fnmadd_f8_rne_formal"
      "test_fnmadd_f8_rtn_formal"
      "test_fnmadd_f8_rton_formal"
      "test_fnmadd_f8_rtop_formal"
      "test_fnmadd_f8_rtp_formal"
      "test_fnmadd_f8_rtz_formal"
      "test_fnmsub_f8_rna_formal"
      "test_fnmsub_f8_rne_formal"
      "test_fnmsub_f8_rtn_formal"
      "test_fnmsub_f8_rton_formal"
      "test_fnmsub_f8_rtop_formal"
      "test_fnmsub_f8_rtp_formal"
      "test_fnmsub_f8_rtz_formal"
      "test_fsub_f16_rna_formal"
      "test_fsub_f16_rne_formal"
      "test_fsub_f16_rtn_formal"
      "test_fsub_f16_rton_formal"
      "test_fsub_f16_rtop_formal"
      "test_fsub_f16_rtp_formal"
      "test_fsub_f16_rtz_formal"
    ];

    pythonImportsCheck = ["ieee754.part"];
  }
