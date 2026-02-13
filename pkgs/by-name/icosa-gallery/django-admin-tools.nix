{
  fetchFromGitHub,
  lib,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "django-admin-tools";
  version = "0.9.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "django-admin-tools";
    repo = "django-admin-tools";
    tag = version;
    hash = "sha256-Ul+XEAiemDj26lQpJqBV+pxxhUui1YXZkkxO6wPhEOY=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  pythonImportsCheck = [
    "admin_tools"
  ];

  meta = {
    description = "Collection of extensions and tools for the Django administration interface";
    homepage = "https://github.com/django-admin-tools/django-admin-tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    teams = with lib.teams; [ ngi ];
  };
}
