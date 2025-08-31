{
  fetchFromGitea,
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "django-honeypot";
  version = "1.3.0";
  pyproject = true;

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "jpt";
    repo = "django-honeypot";
    tag = version;
    hash = "sha256-8j1/p+GD8ac+y/TT2K6SvJAYogAX3QC12LExt/nJeYk=";
  };

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    django
  ];

  pythonImportsCheck = [
    "honeypot"
  ];

  meta = {
    description = "Django honeypot field utilities";
    homepage = "https://codeberg.org/jpt/django-honeypot";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ prince213 ];
    teams = with lib.teams; [ ngi ];
  };
}
