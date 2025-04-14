{
  lib,
  fetchFromLibresoc,
  python3,
  python3Packages,
  nmigen-soc,
  nmigen,
}:
python3Packages.buildPythonPackage rec {
  pname = "c4m-jtag";
  version = "unstable-2024-03-31";
  realVersion = "0.3.dev243+g${lib.substring 0 7 src.rev}";
  pyproject = true;

  src = fetchFromLibresoc {
    inherit pname;
    rev = "f5322d804e8228a2a5715c77185c60148ff96da8"; # HEAD @ version date
    hash = "sha256-0yF/yqcknCq1fre5pnKux4V7guu2oDa6duPO9mU46n8=3";
  };

  prePatch = ''
    export SETUPTOOLS_SCM_PRETEND_VERSION="${realVersion}"
  '';

  nativeBuildInputs = with python3Packages; [ setuptools-scm ];
  propagatedBuildInputs = [ nmigen-soc ];

  pythonImportsCheck = [ "c4m.nmigen.jtag.tap" ];

  meta = {
    description = "Chip4Makers nmigen JTAG implementation";
    homepage = "https://git.libre-soc.org/?p=c4m-jtag.git;a=summary";
  };
}
