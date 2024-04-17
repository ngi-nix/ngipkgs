{
  lib,
  pretalxFull,
  fetchFromGitHub,
}:
pretalxFull.python.pkgs.buildPythonPackage rec {
  pname = "pretalx-public-voting";
  version = "1.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pretalx";
    repo = "pretalx-public-voting";
    rev = "v${version}";
    hash = "sha256-0dSnUVXtWEuu+m5PyFjjM2WVYE3+cNqZYlMkRQlI+2U=";
  };

  build-system = with pretalxFull.python.pkgs; [setuptools];

  pythonImportsCheck = ["pretalx_public_voting"];

  meta = {
    description = "A public voting plugin for pretalx";
    homepage = "https://github.com/pretalx/pretalx-public-voting";
    license = lib.licenses.asl20;
  };
}
