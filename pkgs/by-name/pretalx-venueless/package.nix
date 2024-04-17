{
  lib,
  pretalxFull,
  fetchFromGitHub,
  gettext,
}:
pretalxFull.python.pkgs.buildPythonPackage rec {
  pname = "pretalx-venueless";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pretalx";
    repo = "pretalx-venueless";
    rev = "v${version}";
    hash = "sha256-h8o5q1roFm8Bct/Qf8obIJYkkGPcz3WJ15quxZH48H8=";
  };

  nativeBuildInputs = [gettext];

  build-system = with pretalxFull.python.pkgs; [setuptools];

  dependencies = with pretalxFull.python.pkgs; [
    django
    pyjwt
  ];

  pythonImportsCheck = ["pretalx_venueless"];

  meta = {
    description = "Static venueless for pretalx, e.g. information, venue listings, a Code of Conduct, etc";
    homepage = "https://github.com/pretalx/pretalx-venueless";
    license = lib.licenses.asl20;
  };
}
