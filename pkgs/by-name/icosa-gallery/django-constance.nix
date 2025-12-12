{
  fetchFromGitHub,
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "django-constance";
  version = "4.3.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jazzband";
    repo = "django-constance";
    tag = version;
    hash = "sha256-fs4P4lk6K5eceQ82o7/mW1JLgfuTR0k4799X0VWnG54=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = with python3Packages; [
    django
  ];

  optional-dependencies = with python3Packages; {
    redis = [
      redis
    ];
  };

  pythonImportsCheck = [
    "constance"
  ];

  meta = {
    description = "Dynamic Django settings";
    homepage = "https://github.com/jazzband/django-constance";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prince213 ];
    teams = with lib.teams; [ ngi ];
  };
}
