{
  fetchPypi,
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "django-simple-math-captcha";
  version = "2.0.1";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-U2OkdU2tRhsiMkZoAy4IQi3Jpe9hHTWVD9Pakqh9GtM=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  pythonImportsCheck = [
    "simplemathcaptcha"
  ];

  meta = {
    description = "Math field/widget captcha for Django forms";
    homepage = "https://github.com/alsoicode/django-simple-math-captcha";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prince213 ];
    teams = with lib.teams; [ ngi ];
  };
}
