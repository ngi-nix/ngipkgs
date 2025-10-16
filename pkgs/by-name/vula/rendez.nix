{
  lib,
  python3,
  fetchPypi,
  callPackage,
}:

let
  hkdf = callPackage ./hkdf.nix { };
  pymonocypher = callPackage ./pymonocypher.nix { };
in

python3.pkgs.buildPythonApplication rec {
  pname = "rendez";
  version = "1.2.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-V1hbhlBngIrHHozpR2B+NhTnljHumYvUS9Sz6ms20Eg=";
  };

  build-system = [
    python3.pkgs.flit-core
  ];

  dependencies = with python3.pkgs; [
    click
    cryptography
    flask
    highctidh
    hkdf
    ifaddr
    pymonocypher
    pysocks
    requests
    stem
    toml
  ];

  pythonImportsCheck = [
    "rendez"
  ];

  meta = {
    description = "From rendez.vous import reunion";
    homepage = "https://pypi.org/project/rendez/";
    license = lib.licenses.gpl3Only;
    mainProgram = "rendez";
  };
}
